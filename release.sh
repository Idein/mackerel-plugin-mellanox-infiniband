#!/bin/sh
set -eu

NAME=mackerel-plugin-mellanox-infiniband
GOOS=linux
GOARCH=amd64
ARCHIVE_NAME="${NAME}_${GOOS}_${GOARCH}"
# find git tag for HEAD
TAG="$(git describe --exact-match --abbrev=0 --tags)"
DISTDIR="$(dirname "$0")/dist/${TAG}"

# check HEAD is clean
test -z "$(git ls-files --exclude-standard --others)"

WORKDIR="$(mktemp -d)"
mkdir -p "${WORKDIR}/${ARCHIVE_NAME}"
cp README.md LICENSE "build/linux/amd64/${NAME}" "${WORKDIR}/${ARCHIVE_NAME}"
(cd "${WORKDIR}"; zip -r "${ARCHIVE_NAME}.zip" "${ARCHIVE_NAME}")
rm -rf "${DISTDIR}" && mkdir -p "${DISTDIR}"
cp "${WORKDIR}/${ARCHIVE_NAME}.zip" "${DISTDIR}"
rm -rf "${WORKDIR}"
