#!/bin/bash
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
source tests-common.sh || exit

_INSDESTTREE_=""
insinto() {
	_INSDESTTREE_="$1"
	mkdir -p "${ED}${_INSDESTTREE_}"
}
doins() {
	cp -t "${ED}${_INSDESTTREE_}" "$@"
}

test_default_depend() {
	tbegin "default FONT_AUTO_DEPEND (yes) adds IUSE=X and BDEPEND"
	(
		inherit font
		[[ ${IUSE} =~ (^|[[:space:]])X([[:space:]]|$) ]] || exit 1
		[[ ${BDEPEND} =~ ">=x11-apps/mkfontscale-1.2.0" ]] || exit 1
		[[ ${BDEPEND} =~ "media-fonts/encodings" ]] || exit 1
	)
	tend $?
}

test_opt_out_depend() {
	tbegin "FONT_AUTO_DEPEND=no omits IUSE=X and BDEPEND"
	(
		FONT_AUTO_DEPEND=no
		inherit font
		[[ ! ${IUSE} =~ (^|[[:space:]])X([[:space:]]|$) ]] || exit 1
		[[ -z ${BDEPEND} ]] || exit 1
		[[ ${FONT_DEPEND} =~ ">=x11-apps/mkfontscale-1.2.0" ]] || exit 1
		[[ ${FONT_DEPEND} =~ "media-fonts/encodings" ]] || exit 1
	)
	tend $?
}

test_encodings_depend() {
	tbegin "CATEGORY/PN=media-fonts/encodings does not add self-dependency"
	(
		CATEGORY="media-fonts"
		PN="encodings"
		inherit font
		[[ ! ${IUSE} =~ (^|[[:space:]])X([[:space:]]|$) ]] || exit 1
		[[ -z ${BDEPEND} ]] || exit 1
	)
	tend $?
}

test_xfont_config_use_x_disabled() {
	tbegin "font_xfont_config no-op when in_iuse X && ! use X"
	(
		called=0
		mkfontscale() { called=1; }
		mkfontdir() { called=1; }
		inherit font
		# IUSE contains X by default, but use X is false (in tests-common use checks IUSE, override use)
		use() { return 1; }
		in_iuse() { return 0; }
		font_xfont_config
		[[ ${called} -eq 0 ]]
	)
	tend $?
}

test_xfont_config_use_x_enabled() {
	tbegin "font_xfont_config executes when in_iuse X && use X"
	(
		called_scale=0
		called_dir=0
		mkfontscale() { called_scale=1; }
		mkfontdir() { called_dir=1; }
		inherit font
		use() { return 0; }
		in_iuse() { return 0; }
		mkdir -p "${ED}${FONTDIR}"
		font_xfont_config
		[[ ${called_scale} -eq 1 && ${called_dir} -eq 1 ]]
	)
	tend $?
}

test_xfont_config_no_iuse_x() {
	tbegin "font_xfont_config no-op when X not in IUSE (FONT_AUTO_DEPEND=no)"
	(
		called_scale=0
		called_dir=0
		mkfontscale() { called_scale=1; }
		mkfontdir() { called_dir=1; }
		FONT_AUTO_DEPEND=no
		inherit font
		mkdir -p "${ED}${FONTDIR}"
		font_xfont_config
		[[ ${called_scale} -eq 0 && ${called_dir} -eq 0 ]]
	)
	tend $?
}

test_src_install_opt_out() {
	tbegin "font_src_install with FONT_AUTO_DEPEND=no does not call font_xfont_config"
	(
		called=0
		mkfontscale() { called=1; }
		mkfontdir() { called=1; }
		FONT_AUTO_DEPEND=no
		FONT_SUFFIX="ttf"
		FONT_PN="testfont"
		FONTDIR="/usr/share/fonts/testfont"
		S="${WORKDIR}/testfont"
		mkdir -p "${S}"
		touch "${S}/test.ttf"
		inherit font
		einstalldocs() { :; }
		font_src_install
		[[ -f "${ED}${FONTDIR}/test.ttf" ]] || exit 1
		[[ ${called} -eq 0 ]]
	)
	tend $?
}

test_src_install_use_x() {
	tbegin "font_src_install with default FONT_AUTO_DEPEND calls font_xfont_config when USE=X"
	(
		called=0
		mkfontscale() { called=1; }
		mkfontdir() { called=1; }
		FONT_SUFFIX="ttf"
		FONT_PN="testfont"
		FONTDIR="/usr/share/fonts/testfont"
		S="${WORKDIR}/testfont"
		mkdir -p "${S}"
		touch "${S}/test.ttf"
		inherit font
		use() { [[ $1 == "X" ]] && return 0; return 1; }
		in_iuse() { [[ $1 == "X" ]] && return 0; return 1; }
		einstalldocs() { :; }
		font_src_install
		[[ -f "${ED}${FONTDIR}/test.ttf" ]] || exit 1
		[[ ${called} -eq 1 ]]
	)
	tend $?
}

test_default_depend
test_opt_out_depend
test_encodings_depend
test_xfont_config_use_x_disabled
test_xfont_config_use_x_enabled
test_xfont_config_no_iuse_x
test_src_install_opt_out
test_src_install_use_x

texit
