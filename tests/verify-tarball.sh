#!/bin/sh
set -e

TARBALL=$(find dist -maxdepth 1 -name 'openccu-prometheus-node-exporter-*.tar.gz' | head -n1)

echo "Verifying ${TARBALL}..."

tar -tzf "${TARBALL}" | grep -v '/$' | sort > /tmp/tarball-contents.txt

printf '%s\n' \
  "update_script" \
  "rc.d/node_exporter" \
  "addon/VERSION" \
  "addon/bin/node_exporter" \
  "addon/bin/collect-hm-metrics.tcl" \
  | sort > /tmp/expected-contents.txt

if ! diff -q /tmp/expected-contents.txt /tmp/tarball-contents.txt >/dev/null 2>&1; then
  echo "Tarball contents do not match expected manifest:"
  diff /tmp/expected-contents.txt /tmp/tarball-contents.txt || true
  exit 1
fi

echo "Tarball OK"
