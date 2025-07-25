# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit cmake desktop flag-o-matic python-any-r1 toolchain-funcs xdg verify-sig virtualx

DESCRIPTION="3D photo-realistic skies in real time"
HOMEPAGE="https://stellarium.org/ https://github.com/Stellarium/stellarium"
MY_DSO_VERSION="3.20"
SRC_URI="
	https://github.com/Stellarium/stellarium/releases/download/v${PV}/${P}.tar.xz
	verify-sig? ( https://github.com/Stellarium/stellarium/releases/download/v${PV}/${P}.tar.xz.asc )
	deep-sky? (
		https://github.com/Stellarium/stellarium-data/releases/download/dso-${MY_DSO_VERSION}/catalog-${MY_DSO_VERSION}.dat -> ${PN}-dso-catalog-${MY_DSO_VERSION}.dat
		verify-sig? ( https://github.com/Stellarium/stellarium-data/releases/download/dso-${MY_DSO_VERSION}/catalog-${MY_DSO_VERSION}.dat.asc -> ${PN}-dso-catalog-${MY_DSO_VERSION}.dat.asc )
	)
	doc? (
		https://github.com/Stellarium/stellarium/releases/download/v${PV}/stellarium_user_guide-${PV}-1.pdf
		verify-sig? ( https://github.com/Stellarium/stellarium/releases/download/v${PV}/stellarium_user_guide-${PV}-1.pdf.asc )
	)
	stars? (
		https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_4_1v0_6.cat
		https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_5_1v0_6.cat
		https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_6_1v0_4.cat
		https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_7_1v0_4.cat
		https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_8_2v0_3.cat
		verify-sig? (
			https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_4_1v0_6.cat.asc
			https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_5_1v0_6.cat.asc
			https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_6_1v0_4.cat.asc
			https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_7_1v0_4.cat.asc
			https://github.com/Stellarium/stellarium-data/releases/download/stars-3.0/stars_8_2v0_3.cat.asc
		)
	)"

LICENSE="GPL-2+ SGI-B-2.0"
SLOT="0"
KEYWORDS="~amd64 ~riscv ~x86"
IUSE="debug deep-sky doc gps +lens-distortion libcxx media nls +scripting +show-my-sky stars telescope test webengine +xlsx"

# Python interpreter is used while building RemoteControl plugin
BDEPEND="
	${PYTHON_DEPS}
	dev-lang/perl
	doc? ( app-text/doxygen[dot] )
	nls? ( dev-qt/qttools:6[linguist] )
	verify-sig? ( sec-keys/openpgp-keys-stellarium )
"
# TODO: review need for dev-cpp/tbb after several releases of gcc and clang
RDEPEND="
	dev-cpp/tbb:=
	dev-libs/md4c
	dev-qt/qtbase:6=[concurrent,gui,network,widgets]
	dev-qt/qtcharts:6
	dev-qt/qtpositioning:6
	media-fonts/dejavu
	>=sci-astronomy/calcmysky-0.3.5:=
	sys-libs/zlib
	gps? (
		dev-qt/qtserialport:6
		sci-geosciences/gpsd:=[cxx]
	)
	lens-distortion? (
		media-gfx/exiv2:=
		sci-libs/nlopt
	)
	media? (
		dev-qt/qtmultimedia:6[gstreamer]
		virtual/opengl
	)
	scripting? ( dev-qt/qtdeclarative:6 )
	telescope? (
		dev-qt/qtserialport:6
		sci-libs/indilib:=
	)
	webengine? ( dev-qt/qtwebengine:6[widgets] )
	xlsx? ( >=dev-libs/qxlsx-1.5.0:= )
"
DEPEND="${RDEPEND}
	libcxx? ( dev-cpp/fast_float )
"

RESTRICT="!test? ( test )"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/stellarium.asc

pkg_setup() {
	if tc-is-clang && ! use libcxx && [[ $(tc-get-cxx-stdlib) == libc++ ]]; then
		die "When using libc++, please enable USE=libcxx"
	fi
}

src_prepare() {
	cmake_src_prepare
	use debug || append-cppflags -DQT_NO_DEBUG #415769

	rm -r src/external/qtcompress/ || die
	rm -r src/external/zlib/ || die
	rm -r src/external/fake-indi/ || die

	# for glues_stel aka libtess I couldn't find an upstream with the same API

	local remaining="$(cd src/external/ && echo */)"
	if [[ "${remaining}" != "glues_stel/" ]]; then
		eqawarn "Need to unbundle more deps: ${remaining}"
	fi
}

src_configure() {
	filter-lto # https://bugs.gentoo.org/862249

	local mycmakeargs=(
		-DCCACHE_PROGRAM=no
		-DCPM_LOCAL_PACKAGES_ONLY=yes
		-DUSE_BUNDLED_QTCOMPRESS=no
		-DENABLE_GPS="$(usex gps)"
		-DENABLE_MEDIA="$(usex media)"
		-DENABLE_NLS="$(usex nls)"
		-DENABLE_QT6=yes
		-DENABLE_QTWEBENGINE="$(usex webengine)"
		-DENABLE_SHOWMYSKY=$(usex show-my-sky)
		-DENABLE_SCRIPTING=$(usex scripting)
		-DENABLE_TESTING="$(usex test)"
		-DENABLE_XLSX="$(usex xlsx)"
		-DUSE_PLUGIN_LENSDISTORTIONESTIMATOR="$(usex lens-distortion)"
		-DUSE_PLUGIN_TELESCOPECONTROL="$(usex telescope)"
		"$(cmake_use_find_package doc Doxygen)"
	)
	cmake_src_configure
}

src_test() {
	virtx cmake_src_test
}

src_compile() {
	cmake_src_compile

	if use doc ; then
		cmake_build apidoc
	fi
}

src_install() {
	if use doc ; then
		local HTML_DOCS=( "${BUILD_DIR}/doc/html/." )
		dodoc "${DISTDIR}/stellarium_user_guide-${PV}-1.pdf"
	fi
	cmake_src_install

	# use the more up-to-date system fonts
	rm "${ED}"/usr/share/stellarium/data/DejaVuSans{Mono,}.ttf || die
	dosym ../../fonts/dejavu/DejaVuSans.ttf /usr/share/stellarium/data/DejaVuSans.ttf
	dosym ../../fonts/dejavu/DejaVuSansMono.ttf /usr/share/stellarium/data/DejaVuSansMono.ttf

	if use stars ; then
		insinto /usr/share/${PN}/stars/hip_gaia3
		doins "${DISTDIR}"/stars_{4,5}_1v0_6.cat
		doins "${DISTDIR}"/stars_{6,7}_1v0_4.cat
		doins "${DISTDIR}"/stars_8_2v0_3.cat
	fi
	if use deep-sky ; then
		insinto /usr/share/${PN}/nebulae/default
		newins "${DISTDIR}/${PN}-dso-catalog-${MY_DSO_VERSION}.dat" catalog.dat
	fi
	newicon doc/images/stellarium-logo.png ${PN}.png
}
