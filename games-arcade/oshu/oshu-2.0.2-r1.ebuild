# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake ffmpeg-compat xdg

DESCRIPTION="Lightweight osu! port"
HOMEPAGE="https://github.com/fmang/oshu"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/fmang/oshu.git"
	SRC_URI="osu-skin? ( https://www.mg0.fr/oshu/skins/osu-v1.tar.gz -> ${PN}-skin-v1.tar.gz )"
else
	SRC_URI="https://github.com/fmang/oshu/archive/${PV}.tar.gz -> oshu-${PV}.tar.gz
		osu-skin? ( https://www.mg0.fr/oshu/skins/osu-v1.tar.gz -> ${PN}-skin-v1.tar.gz )"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3 CC-BY-NC-4.0"
SLOT="0"
IUSE="osu-skin"

RDEPEND="
	media-libs/libsdl2
	media-libs/sdl2-image
	x11-libs/cairo
	x11-libs/pango
	media-video/ffmpeg-compat:6=
"

DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/oshu-2.0.2-ffmpeg4-compat.patch" )

src_unpack() {
	default

	if [[ ${PV} = *9999 ]]; then
		git-r3_src_unpack
	fi
}

src_prepare() {
	if use osu-skin; then
		eapply "${FILESDIR}/oshu-2.0.0-use_unpacked_osu-skin.patch"
		mv "${WORKDIR}/osu" share/skins/ || die "Failed to move osu-skin"
	fi

	cmake_src_prepare
}

src_configure() {
	# TODO: fix with >=ffmpeg-7 then drop compat (bug #948392)
	ffmpeg_compat_setup 6
	ffmpeg_compat_add_flags

	local mycmakeargs=(
		-DOSHU_DEFAULT_SKIN=$(usex osu-skin osu minimal)
		-DOSHU_SKINS=minimal$(usev osu-skin ';osu')
	)

	cmake_src_configure
}

src_test() {
	cmake_build check
}
