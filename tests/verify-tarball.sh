#!/bin/sh
set -e

TARBALL=$(find dist -maxdepth 1 -name 'openccu-prometheus-node-exporter-*.tar.gz' | head -n1)

echo "Verifying ${TARBALL}..."

WORKDIR=$(mktemp -d)
trap 'rm -rf "${WORKDIR}"' EXIT

tar -tzf "${TARBALL}" | grep -v '/$' | sort > "${WORKDIR}/tarball-contents.txt"

printf '%s\n' \
  "update_script" \
  "rc.d/node_exporter" \
  "addon/VERSION" \
  "addon/bin/node_exporter" \
  "addon/bin/collect-hm-metrics.tcl" \
  | sort > "${WORKDIR}/expected-contents.txt"

if ! diff -q "${WORKDIR}/expected-contents.txt" "${WORKDIR}/tarball-contents.txt" >/dev/null 2>&1; then
  echo "Tarball contents do not match expected manifest:"
  diff "${WORKDIR}/expected-contents.txt" "${WORKDIR}/tarball-contents.txt" || true
  exit 1
fi

echo "Tarball OK"
