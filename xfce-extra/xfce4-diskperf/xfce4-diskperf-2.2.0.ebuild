# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-diskperf/xfce4-diskperf-2.2.0.ebuild,v 1.8 2008/08/27 15:49:47 armin76 Exp $

EAPI="prefix"

inherit xfce44

xfce44
xfce44_goodies_panel_plugin

DESCRIPTION="Disk usage and performance panel plugin"
KEYWORDS="~amd64-linux ~x86-linux"

DEPEND="dev-util/xfce4-dev-tools
	dev-util/intltool"

src_unpack() {
	unpack ${A}
	cd "${S}"
}
