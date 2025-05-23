# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

MY_P=python-livereload-${PV}
DESCRIPTION="livereload server in Python"
HOMEPAGE="
	https://github.com/lepture/python-livereload/
	https://pypi.org/project/livereload/
"
SRC_URI="
	https://github.com/lepture/python-livereload/archive/v${PV}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm64 x86"
IUSE="examples"

RDEPEND="
	dev-python/tornado[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/pytest-rerunfailures[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
distutils_enable_sphinx docs \
	dev-python/furo \
	dev-python/myst-parser \
	dev-python/sphinxcontrib-programoutput

python_test() {
	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1

	# tests/test_watcher.py::TestWatcher::test_watch_multiple_dirs
	# is extremely flaky
	epytest -p rerunfailures --reruns=10
}

python_install_all() {
	if use examples; then
		docinto examples
		dodoc -r example/.
		docompress -x /usr/share/doc/${PF}/examples
	fi

	distutils-r1_python_install_all
}
