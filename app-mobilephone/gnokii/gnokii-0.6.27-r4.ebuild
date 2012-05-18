# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-mobilephone/gnokii/gnokii-0.6.27-r4.ebuild,v 1.6 2011/03/27 12:11:23 nirbheek Exp $

EAPI=2

inherit eutils linux-info autotools

DESCRIPTION="user space driver and tools for use with mobile phones"
HOMEPAGE="http://www.gnokii.org/"
if [ "$PV" != "9999" ]; then
	SRC_URI="http://www.gnokii.org/download/${PN}/${P}.tar.bz2"
	KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
else
	SRC_URI=""
	KEYWORDS=""
	EGIT_REPO_URI="git://git.savannah.nongnu.org/gnokii.git"
	inherit git
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="nls bluetooth ical irda sms postgres mysql usb X debug"

RDEPEND="!app-mobilephone/smstools
	sys-apps/pcsc-lite
	X? ( x11-libs/gtk+:2 )
	bluetooth? ( kernel_linux? ( net-wireless/bluez ) )
	sms? (
		!app-mobilephone/smstools
		dev-libs/glib:2
		postgres? ( >=dev-db/postgresql-base-8.0 )
		mysql? ( >=virtual/mysql-4.1 )
	)
	ical? ( dev-libs/libical )
	usb? ( =virtual/libusb-0* )
	virtual/libintl"
DEPEND="${RDEPEND}
	irda? ( virtual/os-headers )
	nls? ( sys-devel/gettext )
	dev-util/intltool"

CONFIG_CHECK="~UNIX98_PTYS"

# Supported languages and translated documentation
# Be sure all languages are prefixed with a single space!
MY_AVAILABLE_LINGUAS=" cs de et fi fr it nl pl pt sk sl sv zh_CN"
IUSE="${IUSE} ${MY_AVAILABLE_LINGUAS// / linguas_}"

src_prepare() {
	if [ "$PV" != "9999" ]; then
	    epatch "${FILESDIR}"/${P}-icon.patch
	    epatch "${FILESDIR}"/${P}-disable-database.patch
	    epatch "${FILESDIR}"/${P}-TP-PI.patch
		epatch "${FILESDIR}"/${P}-darwin.patch
	else
	    epatch "${FILESDIR}"/${P}-icon.patch
	    epatch "${FILESDIR}"/${P}-translations.patch
	    intltoolize --force --copy --automake || die "intltoolize error"
	fi

	eautoreconf
}

src_configure() {
	strip-linguas ${MY_AVAILABLE_LINGUAS}

	local config_xdebug="--disable-xdebug"
	use X && use debug && config_xdebug="--enable-xdebug"

	econf \
		$(use_enable nls) \
		$(use_enable ical libical) \
		$(use_enable usb libusb) \
		$(use_enable irda) \
		$(use_enable bluetooth) \
		$(use_with X x) \
		$(use_enable sms smsd) \
		$(use_enable mysql) \
		$(use_enable postgres) \
		$(use_enable debug fulldebug) \
		${config_xdebug} \
		$(use_enable debug rlpdebug) \
		--enable-security \
		--disable-unix98test \
		--enable-libpcsclite \
		|| die "configure failed"
}

src_install() {
	einstall || die "make install failed"

	insinto /etc
	doins Docs/sample/gnokiirc
	sed -i -e 's:/usr/local:'"${EPREFIX}"'/usr:' "${ED}/etc/gnokiirc"

	# only one file needs suid root to make a pseudo device
	fperms 4755 /usr/sbin/mgnokiidev

	if use X; then
		insinto /usr/share/pixmaps
		newins Docs/sample/logo/gnokii.xpm xgnokii.xpm
	fi

	if use sms; then
		pushd "${S}/smsd"
		insinto /usr/share/doc/${PN}/smsd
		use mysql && doins sms.tables.mysql.sql README.MySQL
		use postgres && doins sms.tables.pq.sql
		doins README ChangeLog README.Tru64 action
		popd
	fi
}

pkg_postinst() {
	elog "Make sure the user that runs gnokii has read/write access to the device"
	elog "which your phone is connected to."
	elog "The simple way of doing that is to add your user to the uucp group."
	if [ "$PV" == "9999" ]; then
	    elog "This is the GIT version of ${PN}. It is experimental but may have important bug fixes."
	    elog "You can keep track of the most recent commits at:"
	    elog "    http://git.savannah.gnu.org/cgit/gnokii.git/"
	    elog "Whenever there is a change you are interested in, you can re-emerge ${P}."
	fi
}
