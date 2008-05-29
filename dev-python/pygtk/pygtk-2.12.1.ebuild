# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pygtk/pygtk-2.12.1.ebuild,v 1.4 2008/04/24 19:27:14 drac Exp $

EAPI="prefix"

inherit gnome.org python flag-o-matic eutils virtualx

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc examples"

RDEPEND=">=dev-libs/glib-2.8.0
	>=x11-libs/pango-1.16.0
	>=dev-libs/atk-1.12.0
	>=x11-libs/gtk+-2.11.6
	>=gnome-base/libglade-2.5.0
	>=dev-lang/python-2.4.4-r5
	>=dev-python/pycairo-1.0.2
	>=dev-python/pygobject-2.14
	!arm? ( dev-python/numeric )"

DEPEND="${RDEPEND}
	doc? ( dev-libs/libxslt >=app-text/docbook-xsl-stylesheets-1.70.1 )
	>=dev-util/pkgconfig-0.9"

src_unpack() {
	unpack ${A}

	# disable pyc compiling
	mv "${S}"/py-compile "${S}"/py-compile.orig
	ln -s $(type -P true) "${S}"/py-compile
}

src_compile() {
	use hppa && append-flags -ffunction-sections
	econf $(use_enable doc docs) --enable-thread || die
	# possible problems with parallel builds (#45776)
	#emake -j1 || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile*
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

src_test() {
	cd tests
	Xemake check-local || die "tests failed"
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/share/pygtk/2.0/codegen /usr/$(get_libdir)/python${PYVER}/site-packages/gtk-2.0
}

pkg_postrm() {
	python_version
	python_mod_cleanup /usr/share/pygtk/2.0/codegen
	python_mod_cleanup
	rm -f "${EROOT}"/usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.{py,pth}
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.py pygtk.py-[0-9].[0-9]
	alternatives_auto_makesym /usr/$(get_libdir)/python${PYVER}/site-packages/pygtk.pth pygtk.pth-[0-9].[0-9]
}
