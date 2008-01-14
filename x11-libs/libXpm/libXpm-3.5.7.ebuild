# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXpm/libXpm-3.5.7.ebuild,v 1.7 2008/01/13 09:23:21 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xpm library"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXext"
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_compile() {
	# the gettext configure check and code in sxpm are incorrect; they assume
	# gettext being in libintl, whereas Solaris has gettext by default
	# resulting in libintl not being added to LIBS
	[[ ${CHOST} == *-solaris* ]] && append-ldflags -lintl
	x-modular_src_compile
}
