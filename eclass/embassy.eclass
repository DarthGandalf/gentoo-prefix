# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/embassy.eclass,v 1.15 2007/08/07 18:30:04 ribosome Exp $

# Author Olivier Fisette <ribosome@gentoo.org>

# This eclass is used to install EMBASSY programs (EMBOSS add-ons).

# The inheriting ebuild should provide a "DESCRIPTION", "KEYWORDS" and, if
# necessary, add "(R|P)DEPEND"encies. Additionnaly, the inheriting ebuild's
# name must begin by "embassy-". Also, before inheriting, the ebuild should
# specify what version of EMBOSS is required by setting EBOV.

inherit eutils multilib

# The EMBASSY package name, retrieved from the inheriting ebuild's name
EN=${PN:8}
# The full name and version of the EMBASSY package (excluding the Gentoo
# revision number)
EF="$(echo ${EN} | tr "[:lower:]" "[:upper:]")-${PV}"

DESCRIPTION="Based on the $ECLASS eclass"
HOMEPAGE="http://emboss.sourceforge.net/"
LICENSE="LGPL-2 GPL-2"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	ftp://emboss.open-bio.org/pub/EMBOSS/${EF}.tar.gz"

SLOT="0"
IUSE="X png"

DEPEND="=sci-biology/emboss-${EBOV}*
	!<sci-biology/emboss-${EBOV}
	X? ( x11-libs/libX11 )
	png? ( sys-libs/zlib
		media-libs/libpng
		>=media-libs/gd-1.8
	)"

S=${WORKDIR}/EMBOSS-${EBOV}/embassy/${EF}

embassy_src_unpack() {
	unpack ${A}
	mkdir EMBOSS-${EBOV}/embassy
	mv ${EF} EMBOSS-${EBOV}/embassy/
	cp "${EPREFIX}"/usr/$(get_libdir)/libplplot.la EMBOSS-${EBOV}/plplot/
	cp "${EPREFIX}"/usr/$(get_libdir)/libeplplot.la EMBOSS-${EBOV}/plplot/
	cp "${EPREFIX}"/usr/$(get_libdir)/libajax.la EMBOSS-${EBOV}/ajax/
	cp "${EPREFIX}"/usr/$(get_libdir)/libajaxg.la EMBOSS-${EBOV}/ajax/
	cp "${EPREFIX}"/usr/$(get_libdir)/libnucleus.la EMBOSS-${EBOV}/nucleus/
	if [ -e ${FILESDIR}/${PF}.patch ]; then
		cd ${S}
		epatch ${FILESDIR}/${PF}.patch
	fi
}

embassy_src_compile() {
	local EXTRA_CONF
	! use X && EXTRA_CONF="${EXTRA_CONF} --without-x"
	! use png && EXTRA_CONF="${EXTRA_CONF} --without-pngdriver"
	./configure --host=${CHOST} \
		--mandir="${EPREFIX}"/usr/share/man \
		--infodir="${EPREFIX}"/usr/share/info \
		--datadir="${EPREFIX}"/usr/share \
		--sysconfdir="${EPREFIX}"/etc \
		--localstatedir="${EPREFIX}"/var/lib \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		${EXTRA_CONF} || die
	emake || die "Before reporting this error as a bug, please make sure you compiled
    EMBOSS and the EMBASSY packages with the same \"USE\" flags. Failure to
    do so may prevent the compilation of some EMBASSY packages, or cause
    runtime problems with some EMBASSY programs. For example, if you
    compile EMBOSS with \"png\" support and then try to build DOMAINATRIX
    without \"png\" support, compilation will fail when linking the binaries."
}

embassy_src_install() {
	emake DESTDIR="${D}" install || die "Install failed"
	dodoc AUTHORS ChangeLog NEWS README
}

EXPORT_FUNCTIONS src_unpack src_compile src_install
