# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

TOOLCHAIN_PATCH_DEV="sam"
PATCH_GCC_VER="14.1.0"
PATCH_VER="3"
MUSL_VER="1"
MUSL_GCC_VER="14.1.0"
PYTHON_COMPAT=( python3_{10..12} )

if [[ -n ${TOOLCHAIN_GCC_RC} ]] ; then
	# Cheesy hack for RCs
	MY_PV=$(ver_cut 1).$((($(ver_cut 2) + 1))).$((($(ver_cut 3) - 1)))-RC-$(ver_cut 5)
	MY_P=${PN}-${MY_PV}
	GCC_TARBALL_SRC_URI="mirror://gcc/snapshots/${MY_PV}/${MY_P}.tar.xz"
	TOOLCHAIN_SET_S=no
	S="${WORKDIR}"/${MY_P}
fi

inherit toolchain

if tc_is_live ; then
	# Needs to be after inherit (for now?), bug #830908
	EGIT_BRANCH=releases/gcc-$(ver_cut 1)
elif [[ -z ${TOOLCHAIN_USE_GIT_PATCHES} ]] ; then
	# Don't keyword live ebuilds
	KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
fi

# use alternate source for Apple M1 (also works for x86_64)
SRC_URI+=" elibc_Darwin? ( https://raw.githubusercontent.com/Homebrew/formula-patches/82b5c1cd38826ab67ac7fc498a8fe74376a40f4a/gcc/gcc-14.1.0.diff -> gcc-14.1.0-arm64-darwin.patch https://github.com/iains/gcc-14-branch/commit/75ff8c390327ac693f6a1c40510bc0d35d7a1e22.patch?full_index=1 -> gcc-14.1.0-macos-SDK-availability.patch )"
IUSE+=" bootstrap"

if [[ ${CATEGORY} != cross-* ]] ; then
	# Technically only if USE=hardened *too* right now, but no point in complicating it further.
	# If GCC is enabling CET by default, we need glibc to be built with support for it.
	# bug #830454
	RDEPEND="!prefix-guest? ( elibc_glibc? ( sys-libs/glibc[cet(-)?] ) )"
	DEPEND="${RDEPEND}"
fi

src_prepare() {
	# apply big arm64-darwin patch first thing
	use elibc_Darwin && eapply \
		"${DISTDIR}"/gcc-14.1.0-arm64-darwin.patch \
		"${DISTDIR}"/gcc-14.1.0-macos-SDK-availability.patch

	# make sure 64-bits native targets don't screw up the linker paths
	eapply "${FILESDIR}"/gcc-12-no-libs-for-startfile.patch

	local p upstreamed_patches=(
		# add them here
	)
	for p in "${upstreamed_patches[@]}"; do
		rm -v "${WORKDIR}/patch/${p}" || die
	done

	toolchain_src_prepare
	#
	# make it have correct install_names on Darwin
	eapply -p1 "${FILESDIR}"/4.3.3/darwin-libgcc_s-installname.patch

	if [[ ${CHOST} == powerpc*-darwin* ]] ; then
		# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=44107
		sed -i -e 's|^ifeq (/usr/lib,|ifneq (/usr/lib,|' \
			libgcc/config/t-slibgcc-darwin || die
	fi

	if [[ ${CHOST} == *-solaris* ]] ; then
		# madvise is not available in the compatibility mode GCC uses,
		# posix_madvise however, is
		sed -i -e 's/madvise/posix_madvise/' gcc/cp/module.cc || die
	fi

	if [[ ${CHOST} == *-darwin* ]] ; then
		use bootstrap && eapply "${FILESDIR}"/${PN}-13-darwin14-bootstrap.patch

		# our ld64 is a slight bit different, so tweak expression to not
		# get confused and break the build
		sed -i -e "s/EGREP 'ld64|dyld'/& | head -n1/" \
			gcc/configure{.ac,} || die

		# rip out specific macos version min
		sed -i -e 's/-mmacosx-version-min=11.0//' \
			libgcc/config/aarch64/t-darwin \
			libgcc/config/aarch64/t-heap-trampoline \
			|| die
	fi

	eapply "${FILESDIR}"/${PN}-13-fix-cross-fixincludes.patch
	eapply_user
}
