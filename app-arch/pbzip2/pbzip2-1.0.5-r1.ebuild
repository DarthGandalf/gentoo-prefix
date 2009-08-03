# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/pbzip2/pbzip2-1.0.5-r1.ebuild,v 1.5 2009/08/02 10:31:02 armin76 Exp $

inherit multilib eutils

DESCRIPTION="parallel bzip2 (de)compressor using libbz2"
HOMEPAGE="http://compression.ca/pbzip2/"
SRC_URI="http://compression.ca/${PN}/${P}.tar.gz"

LICENSE="PBZIP2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="static"

DEPEND="app-arch/bzip2"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	sed -e 's:^CFLAGS = .*$:#&:g' -e 's:g++:$(CXX):g' -i ${P}/Makefile || die
	epatch "${FILESDIR}"/${P}-ldflags.patch
}

src_compile() {
	tc-export CXX
	if use static ; then
		cp -f "${EPREFIX}"/usr/$(get_libdir)/libbz2.a "${S}"
		emake pbzip2-static || die "Failed to build"
	else
		emake pbzip2 || die "Failed to build"
	fi
}

src_install() {
	dobin pbzip2 || die "Failed to install"
	dodoc AUTHORS ChangeLog README
	doman pbzip2.1 || die "Failed to install man page"
	dosym /usr/bin/pbzip2 /usr/bin/pbunzip2
}
