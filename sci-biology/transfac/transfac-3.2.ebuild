# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/transfac/transfac-3.2.ebuild,v 1.13 2006/11/02 20:51:49 grobian Exp $

EAPI="prefix"

DESCRIPTION="A database of eucaryotic transcription factors"
HOMEPAGE="http://www.gene-regulation.com/pub/databases.html"
SRC_URI="ftp://ftp.ebi.ac.uk/pub/databases/${PN}/${PN}32.tar.Z"
LICENSE="public-domain"

SLOT="3"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="emboss minimal"
# Minimal build keeps only the indexed files (if applicable) and the documentation.
# The non-indexed database is not installed.

DEPEND="emboss? ( sci-biology/emboss )"

S="${WORKDIR}"

src_compile() {
	if use emboss; then
		echo
		einfo "Indexing TRANSFAC for usage with EMBOSS."
		EMBOSS_DATA=. tfextract -auto -infile class.dat  || die \
			"Indexing TRANSFAC failed."
		echo
	fi
}

src_install() {
	if ! use minimal; then
		insinto /usr/share/${PN}-${SLOT}
		doins *.dat || die
	fi
	if use emboss; then
		insinto /usr/share/EMBOSS/data
		doins tf* || die
	fi
}
