# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools

DESCRIPTION="Utility to report status of an HP (Compaq) array controller (both IDA & CCISS)"
HOMEPAGE="http://www.strocamp.net/opensource/arrayprobe.php"
SRC_URI="http://www.strocamp.net/opensource/compaq/downloads/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"

PATCHES=(
	"${FILESDIR}/${PV}-malloc-strlen.patch"
	"${FILESDIR}/${PV}-ida_headers.patch"
)

src_prepare() {
	default
	eautoreconf
}
