# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="LXQt about dialog"
HOMEPAGE="https://lxqt-project.org/"

MY_PV="$(ver_cut 1-2)"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/lxqt/${PN}.git"
else
	SRC_URI="https://github.com/lxqt/${PN}/releases/download/${PV}/${P}.tar.xz"
	KEYWORDS="amd64 arm64 ~ppc64 ~riscv ~x86"
fi

LICENSE="LGPL-2.1+"
SLOT="0"

BDEPEND=">=dev-util/lxqt-build-tools-2.2.0"
DEPEND="
	>=dev-libs/libqtxdg-4.2.0
	>=dev-qt/qtbase-6.6:6
	=lxqt-base/liblxqt-${MY_PV}*:=
"
RDEPEND="${DEPEND}"
