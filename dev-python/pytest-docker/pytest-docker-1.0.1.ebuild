# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYPI_NO_NORMALIZE=1
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 pypi

DESCRIPTION="Simple pytest fixtures for Docker and Docker Compose based tests"
HOMEPAGE="
	https://github.com/avast/pytest-docker/
	https://pypi.org/project/pytest-docker/
"

SLOT="0"
LICENSE="MIT"
KEYWORDS="~amd64"

RDEPEND="
	<dev-python/pytest-8.0[${PYTHON_USEDEP}]
	dev-python/attrs[${PYTHON_USEDEP}]
"
# BDEPEND="
# 	test? (
# 		dev-python/pycodestyle[${PYTHON_USEDEP}]
# 		dev-python/pylint[${PYTHON_USEDEP}]
# 		dev-python/requests[${PYTHON_USEDEP}]
# 	)
# "

# distutils_enable_tests pytest

# python_test() {
# 	epytest -o addopts=
# }
