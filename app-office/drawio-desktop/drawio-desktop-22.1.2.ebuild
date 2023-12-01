# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="draw.io"
MY_NODE_N="node-modules"
MY_NODE_D="node_modules"
DRAWIO_V="22.1.4"

inherit desktop xdg

DESCRIPTION="draw.io diagramming and whiteboarding desktop app"
HOMEPAGE="https://www.drawio.com/"

SRC_URI="
	https://github.com/jgraph/drawio-desktop/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/jgraph/drawio/archive/refs/tags/v${DRAWIO_V}.tar.gz
	https://github.com/MocioF/distfiles/raw/main/${PN}-${MY_NODE_N}-${PV}-${DRAWIO_V}.tar.xz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=net-libs/nodejs-16[ssl]
	>=dev-libs/nss-3
	app-accessibility/at-spi2-core:2
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libdrm
	x11-libs/libxcb:=
	x11-libs/libxkbcommon
	x11-libs/pango
"

MY_NODE_DIR="${S}/${MY_NODE_D}/"

src_prepare() {
	default
	# We will use pre-generated npm stuff.
	mv "${WORKDIR}/${MY_NODE_D}" "${MY_NODE_DIR}" || die "couldn't move node_modules"

	# Remove unneeded modules with Pre-stripped files
	rm -r "${MY_NODE_DIR}/7zip-bin" || die "couldn't remove 7zip-bin module"
	rm -r "${MY_NODE_DIR}/app-builder-bin" || die "couldn't remove app-builder-bin module"

	# Move drawio sources.
	rm -r "${WORKDIR}/${P}/drawio" || die "couldn't remove old drawio dir"
	mv "${WORKDIR}/drawio-${DRAWIO_V}" "${WORKDIR}/${P}/drawio" || die "couldn't move drawio sources"
}

src_install() {
	# Copy node_modules dir
	insinto "/usr/share/${PN}/"
	insopts -m0755
	doins -r "${MY_NODE_D}/"

	# Copy src dir
	insinto "/usr/share/${PN}/"
	insopts -m0755
	doins -r "src/"

	# Copy drawio and package.json
	insopts -m0644
	doins package.json
	doins -r "drawio/"

	# Copy sync.js even if it should be used only for update drawio
	insopts -m0755
	doins sync.js

	# Create executable
	exeinto /usr/bin
	newexe - ${PN} < <(sed s/@DD_VER@/${PV}/g "${FILESDIR}/drawio-desktop.sh" || die)

	# Copy icons
	newicon -s scalable "${S}/build/icon.svg" drawio.svg
	newicon -s scalable -c mimetypes "${S}/build/icon.svg" application-vnd.jgraph.mxfile.svg
	local IC_SIZE
	for IC_SIZE in 16 32 48 64 96 128 192 256 512 1024
	do
		newicon -s "${IC_SIZE}" "${S}/build/${IC_SIZE}x${IC_SIZE}.png" drawio.png
		newicon -s "${IC_SIZE}" -c mimetypes "${S}/build/${IC_SIZE}x${IC_SIZE}.png" application-vnd.jgraph.mxfile.png
	done

	# Create a desktop entry and associate it with the drawio mime type
	make_desktop_entry "${PN} %U" "${MY_PN}" drawio "Graphics;2DGraphics" \
	"MimeType=application/vnd.jgraph.mxfile;application/vnd.visio;\nStartupWMClass=draw.io;"

	# MIME descriptor for .drawio and .vsdx files
	insinto /usr/share/mime/packages
	doins "${FILESDIR}/${PN}.xml"

	dodoc README.md SECURITY.md
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
