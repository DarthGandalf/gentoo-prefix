# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/pysqlite/pysqlite-2.3.4-r1.ebuild,v 1.1 2007/07/07 13:44:32 hawking Exp $

EAPI="prefix"

NEED_PYTHON=2.3

inherit distutils

DESCRIPTION="Python wrapper for the local database Sqlite"
SRC_URI="http://initd.org/pub/software/pysqlite/releases/${PV:0:3}/${PV}/pysqlite-${PV}.tar.gz"
HOMEPAGE="http://initd.org/tracker/pysqlite/"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
LICENSE="pysqlite"
SLOT="2"
IUSE="examples"

DEPEND=">=dev-db/sqlite-3.1"

PYTHON_MODNAME="pysqlite2"

src_unpack() {
	distutils_src_unpack
	# don't install pysqlite2.test
	sed -i -e 's/, "pysqlite2.test"//' \
		setup.py || die "sed in setup.py failed"
	# workaround to make checks work without installing them
	sed -i -e "s/pysqlite2.test/test/" \
		pysqlite2/test/__init__.py || die "sed failed"
	# correct encoding
	sed -i -e "s/\(coding: \)ISO-8859-1/\1utf-8/" \
		pysqlite2/__init__.py pysqlite2/dbapi2.py || die "sed failed"

	# setup.cfg has hardcoded non-prefix paths, kill them
	cd "${S}"
	sed -i \
		-e '/^include_dirs=/d' \
		-e '/^library_dirs=/d' \
		setup.cfg
}

src_install() {
	DOCS="doc/usage-guide.txt"
	distutils_src_install

	rm -rf "${ED}"/usr/pysqlite2-doc

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r doc/code
	fi
}

src_test() {
	cd pysqlite2
	# tests use this as a nonexistant file
	addpredict /foo/bar
	PYTHONPATH="$(ls -d ../build/lib.*)" "${python}" -c \
		"from test import test;import sys;sys.exit(test())" \
		|| die "test failed"
}
