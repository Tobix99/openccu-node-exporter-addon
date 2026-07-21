ADDON_NAME := node_exporter
NODE_EXPORTER_VERSION := $(shell cat .node_exporter_version)
VERSION := $(NODE_EXPORTER_VERSION)
ARCH := amd64
BUILD_DIR := build
DIST_DIR := dist

TARBALL_NAME := openccu-prometheus-node-exporter-$(VERSION).tar.gz

.PHONY: all clean build verify

all: build

$(BUILD_DIR)/node_exporter-$(NODE_EXPORTER_VERSION).linux-$(ARCH).tar.gz:
	@mkdir -p $(BUILD_DIR)
	curl -fsSL -o $@ https://github.com/prometheus/node_exporter/releases/download/v$(NODE_EXPORTER_VERSION)/node_exporter-$(NODE_EXPORTER_VERSION).linux-$(ARCH).tar.gz
	cd $(BUILD_DIR) && sha256sum -c ../.node_exporter_checksums

$(BUILD_DIR)/node_exporter: $(BUILD_DIR)/node_exporter-$(NODE_EXPORTER_VERSION).linux-$(ARCH).tar.gz
	tar -xzf $< -C $(BUILD_DIR) --strip-components=1 node_exporter-$(NODE_EXPORTER_VERSION).linux-$(ARCH)/node_exporter
	touch $@

$(BUILD_DIR)/addon: $(BUILD_DIR)/node_exporter
	@mkdir -p $@/bin $(BUILD_DIR)/rc.d
	cp $(BUILD_DIR)/node_exporter $@/bin/
	cp bin/collect-hm-metrics.tcl $@/bin/
	cp update_script $(BUILD_DIR)/
	cp rc.d/node_exporter $(BUILD_DIR)/rc.d/
	echo "$(VERSION)" > $@/VERSION
	chmod +x $(BUILD_DIR)/update_script $(BUILD_DIR)/rc.d/node_exporter $@/bin/*
	touch $@

build: $(BUILD_DIR)/addon
	@mkdir -p $(DIST_DIR)
	tar -czf $(DIST_DIR)/$(TARBALL_NAME) -C $(BUILD_DIR) update_script addon rc.d

verify: build
	@sh tests/verify-tarball.sh

clean:
	rm -rf $(BUILD_DIR) $(DIST_DIR)
