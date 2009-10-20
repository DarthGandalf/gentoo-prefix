# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/ca-certificates/ca-certificates-20090709.ebuild,v 1.6 2009/10/09 02:13:09 rich0 Exp $

inherit eutils

DESCRIPTION="Common CA Certificates PEM files"
HOMEPAGE="http://packages.debian.org/sid/ca-certificates"
SRC_URI="mirror://debian/pool/main/c/${PN}/${PN}_${PV}_all.deb"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

DEPEND="|| ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp sys-freebsd/freebsd-ubin )
	sys-apps/debianutils
	kernel_AIX? ( app-arch/deb2targz )" # platforms like AIX don't have a good ar
RDEPEND="dev-libs/openssl"

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	unpack ./data.tar.gz
	rm -f control.tar.gz data.tar.gz debian-binary

	# dirty prefix job (someone gotta do it...)
	sed -i -e "1s|^.*$|#!${EPREFIX}/bin/bash -e|" \
		-e "/^\(CERTSCONF\|CERTSDIR\|ETCCERTSDIR\|  HOOKSDIR\)=/s|=|=\"${EPREFIX}\"|" \
		usr/sbin/update-ca-certificates || die "Can't prefixify"
}

pkg_setup() {
	# For the conversion to having it in CONFIG_PROTECT_MASK,
	# we need to tell users about it once manually first.
	[[ -f ${EPREFIX}/etc/env.d/98ca-certificates ]] \
		|| ewarn "You should run update-ca-certificates manually after etc-update"
}

src_install() {
	mkdir -p "${ED}"
	cp -pPR * "${ED}"/ || die "installing data failed"

	(
	echo "# Automatically generated by ${CAT}/${PF}"
	echo "# $(date -u)"
	echo "# Do not edit."
	cd "${ED}"/usr/share/ca-certificates
	find . -name '*.crt' | sort | cut -b3-
	) > "${ED}"/etc/ca-certificates.conf

	mv "${ED}"/usr/share/doc/{ca-certificates,${PF}} || die
	prepalldocs

	echo 'CONFIG_PROTECT_MASK="/etc/ca-certificates.conf"' > 98ca-certificates
	doenvd 98ca-certificates
}

pkg_postinst() {
	if [ "${ROOT}" = "/" ] ; then
		# However it's too overzealous when the user has custom certs in place.
		# --fresh is to clean up dangling symlinks
		update-ca-certificates
	fi

	local badcerts=0
	for c in $(find -L "${EROOT}"etc/ssl/certs/ -type l) ; do
		ewarn "Broken symlink for a certificate at $c"
		badcerts=1
	done
	if [ $badcerts -eq 1 ]; then
		ewarn "You MUST remove the above broken symlinks"
		ewarn "Otherwise any SSL validation that use the directory may fail!"
		ewarn "To batch-remove them, run:"
		ewarn "find -L ${EROOT}etc/ssl/certs/ -type l -exec rm {} +"
	fi
}
