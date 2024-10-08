# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

GNOME2_LA_PUNT="yes"
inherit autotools gnome2

DESCRIPTION="A simple image viewer widget for GTK"
HOMEPAGE="https://projects.gnome.org/gtkimageview/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~x64-solaris"
IUSE="examples static-libs"

# tests are severely broken, bug #483952
RESTRICT="test"

RDEPEND="x11-libs/gtk+:2"
DEPEND="gnome-base/gnome-common"
BDEPEND="
	dev-build/gtk-doc-am
	gnome-base/gnome-common
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.6.4-slibtool-undefined-references.patch
)

src_prepare() {
	gnome2_src_prepare

	# Prevent excessive build failures due to gcc changes
	sed -e '/CFLAGS/s/-Werror //g' -i configure.in || die

	# Gold linker fix
	sed -e '/libtest.la/s:$: -lm:g' -i tests/Makefile.am || die

	# Don't rebuild gtk-doc
	sed "/^TARGET_DIR/i \GTKDOC_REBASE=true" -i gtk-doc.make || die

	mv configure.in configure.ac || die
	AT_NOELIBTOOLIZE=yes eautoreconf
}

src_configure() {
	gnome2_src_configure \
		$(use_enable static-libs static)
}

src_install() {
	gnome2_src_install

	if use examples ; then
		docinto examples
		dodoc tests/ex-*.c
	fi
}
