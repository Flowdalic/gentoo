# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=ETJ
DIST_VERSION=0.9735
inherit perl-module

DESCRIPTION="Data structure and ops for directed graphs"

SLOT="0"
KEYWORDS="~alpha amd64 ppc sparc x86"

RDEPEND="
	>=dev-perl/Heap-0.800.0
	>=virtual/perl-Scalar-List-Utils-1.450.0
	>=dev-perl/Set-Object-1.400.0
	>=virtual/perl-Storable-2.50.0
"
BDEPEND="
	${RDEPEND}
	test? (
		>=virtual/perl-Test-Simple-0.820.0
	)
"
