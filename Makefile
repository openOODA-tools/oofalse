# ==============================================================================
# oofalse: Sovereign POSIX False & Deterministic Exit Status Analyzer
# Verification, Build, Test, and Packaging Lifecycle Makefile
# ==============================================================================

SHELL := /bin/bash
BIN := dist/oofalse
SRC := $(shell find . -name "*.oo" -not -path "./dist/*")
VERSION ?= 0.2.0

OODA_COMPILER ?= /home/ubermetroid/.openooda/bin/oodac
OODACODEX ?= /home/ubermetroid/.openooda/northstar.oot
OO_LIST_AMBIENT_QUOTA ?= 8589934592

.PHONY: all verify build test package clean check line-cap file-law academy density package-deb package-rpm package-arch

all: verify build test

$(BIN): $(SRC)
	@mkdir -p dist
	OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) \
	OODACODEX=$(OODACODEX) \
	OODA_COMPILER=$(OODA_COMPILER) \
	OODA_NO_JAIL=1 \
	$(OODA_COMPILER) build main.oo -o $(BIN)
	@cp $(BIN) dist/oofalse-linux-x86_64
	@cd dist && sha256sum oofalse-linux-x86_64 > oofalse-linux-x86_64.sha256
	@echo "built $(BIN) (and dist/oofalse-linux-x86_64)"

build: $(BIN)

line-cap:
	@violations=0; \
	for f in $$(find . -name "*.oo" -o -name "*.oot" | grep -v '\.git' | grep -v 'dist/'); do \
		lines=$$(wc -l < "$$f"); \
		if grep -q '^// # ' "$$f" && [ $$lines -lt 16 ]; then \
			echo "VIOLATION: $$f has $$lines lines (< 16 floor)"; violations=$$((violations+1)); \
		fi; \
		if [ $$lines -gt 256 ]; then \
			echo "VIOLATION: $$f has $$lines lines (> 256 cap)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations files violate line bounds"; exit 1; fi; \
	echo "PASS: Page Rule sizing (16-256 lines, shims exempt from floor) holds"

file-law:
	@bad=$$(find . -name "*.oo" | grep -E '(utils?|helpers?|common|misc|shared|base)\.oo$$' | grep -v 'dist/' || true); \
	if [ -n "$$bad" ]; then \
		echo "VIOLATION: Generic drawer filenames detected:"; echo "$$bad"; exit 1; \
	fi; \
	echo "PASS: file law holds"

academy:
	@missing=0; \
	for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		hdr=$$(head -n 7 "$$f"); \
		for elem in "// # " "// Logline:" "// Setup:" "// Beats:"; do \
			if ! echo "$$hdr" | grep -qF "$$elem"; then \
				echo "VIOLATION: $$f missing '$$elem' in first 7 lines"; missing=$$((missing+1)); \
			fi; \
		done; \
	done; \
	if [ $$missing -gt 0 ]; then echo "FAIL: $$missing missing Academy header elements"; exit 1; fi; \
	echo "PASS: academy headers hold (all 4 elements present in first 7 lines)"

density:
	@violations=0; \
	for d in $$(find . -maxdepth 3 -type d -not -path '*/.*' -not -path './dist*' -not -path './packaging*'); do \
		n=$$(ls "$$d"/*.oo "$$d"/*.oot 2>/dev/null | grep -v '\*' | wc -l); \
		if [ $$n -gt 8 ]; then \
			echo "VIOLATION: $$d holds $$n pages (exceeds 8)"; violations=$$((violations+1)); \
		fi; \
	done; \
	if [ $$violations -gt 0 ]; then echo "FAIL: $$violations directories exceed the density bound"; exit 1; fi; \
	echo "PASS: directory density (<= 8 pages per directory) holds"

check:
	@for f in $$(find . -name "*.oo" -not -path "./dist/*"); do \
		OO_LIST_AMBIENT_QUOTA=$(OO_LIST_AMBIENT_QUOTA) OODACODEX=$(OODACODEX) OODA_COMPILER=$(OODA_COMPILER) OODA_NO_JAIL=1 $(OODA_COMPILER) check "$$f" > /dev/null || exit 1; \
	done; \
	echo "PASS: oodac check holds on all .oo files"

verify: line-cap file-law academy density check

test: $(BIN)
	@echo "=== testing --help ==="
	@./$(BIN) --help | grep -q "oofalse" && echo "PASS: --help"
	@echo "=== testing --version ==="
	@./$(BIN) --version | grep -q "oofalse" && echo "PASS: --version"
	@echo "=== testing internal anchors ==="
	@./$(BIN) --test | grep -q "PASSED" && echo "PASS: internal anchors"
	@echo "=== testing default exit code 1 ==="
	@! ./$(BIN) > /dev/null 2>&1 && echo "PASS: default exit status 1"
	@echo "=== testing custom exit code -c 2 ==="
	@./$(BIN) -c 2 > /dev/null 2>&1; [ $$? -eq 2 ] && echo "PASS: -c 2 returns status 2"
	@echo "=== testing custom exit code -c 42 ==="
	@./$(BIN) -c 42 > /dev/null 2>&1; [ $$? -eq 42 ] && echo "PASS: -c 42 returns status 42"
	@echo "=== testing custom message -m ==="
	@output=$$(./$(BIN) -m "critical error" 2>&1 || true); echo "$$output" | grep -q "critical error" && echo "PASS: -m message"
	@echo "=== testing --explain -e ==="
	@output=$$(./$(BIN) -e 2>&1 || true); echo "$$output" | grep -q "GENERAL_ERROR" && echo "PASS: -e explain table"
	@echo "=== testing JSON output -j ==="
	@output=$$(./$(BIN) -j 2>&1 || true); echo "$$output" | grep -q '"exit_code": 1' && echo "PASS: JSON output"
	@echo "=== testing --demo -D ==="
	@output=$$(./$(BIN) -D 2>&1 || true); echo "$$output" | grep -q "Showcase" && echo "PASS: --demo"
	@echo "=== testing MCP initialize ==="
	@printf '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}\n' | ./$(BIN) --mcp | grep -q "protocolVersion" && echo "PASS: MCP initialize"
	@echo "=== testing MCP tools/list ==="
	@printf '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}\n' | ./$(BIN) --mcp | grep -q "false_eval" && echo "PASS: MCP tools/list"
	@echo "=== testing MCP tools/call false_eval ==="
	@printf '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"false_eval","arguments":{"code":1,"message":"test"}}}\n' | ./$(BIN) --mcp | grep -q "GENERAL_ERROR" && echo "PASS: MCP false_eval"
	@echo "=== testing MCP tools/call false_exit_code ==="
	@printf '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"false_exit_code","arguments":{"code":130}}}\n' | ./$(BIN) --mcp | grep -q "FATAL_SIGINT" && echo "PASS: MCP false_exit_code"
	@echo "=== testing MCP tools/call false_assert ==="
	@printf '{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"false_assert","arguments":{"condition":false}}}\n' | ./$(BIN) --mcp | grep -q "ASSERTION_PASSED" && echo "PASS: MCP false_assert"
	@echo "=== testing MCP tools/call false_simulate ==="
	@printf '{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"false_simulate","arguments":{"code":1}}}\n' | ./$(BIN) --mcp | grep -q "errexit" && echo "PASS: MCP false_simulate"
	@echo "=== testing MCP tools/call false_demo ==="
	@printf '{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"false_demo","arguments":{}}}\n' | ./$(BIN) --mcp | grep -q "Showcase" && echo "PASS: MCP false_demo"
	@echo "ALL TESTS PASSED"

package-deb: $(BIN)
	@mkdir -p dist/deb-root/DEBIAN dist/deb-root/usr/bin
	@sed "s/^Version:.*/Version: $(VERSION)-1/" packaging/debian/control.binary > dist/deb-root/DEBIAN/control
	@cp $(BIN) dist/deb-root/usr/bin/oofalse
	@chmod 0755 dist/deb-root/usr/bin/oofalse
	@cp uninstall.sh dist/deb-root/usr/bin/oofalse-uninstall
	@chmod 0755 dist/deb-root/usr/bin/oofalse-uninstall
	@dpkg-deb --build --root-owner-group dist/deb-root dist/oofalse_$(VERSION)-1_amd64.deb
	@rm -rf dist/deb-root
	@echo "built dist/oofalse_$(VERSION)-1_amd64.deb"

package-rpm: $(BIN)
	@mkdir -p ~/rpmbuild/SOURCES ~/rpmbuild/SPECS ~/rpmbuild/RPMS
	@cp $(BIN) ~/rpmbuild/SOURCES/oofalse-linux-x86_64
	@cp uninstall.sh ~/rpmbuild/SOURCES/uninstall.sh
	@sed "s/^Version:.*/Version: $(VERSION)/" packaging/oofalse.spec > ~/rpmbuild/SPECS/oofalse.spec
	@rpmbuild -bb ~/rpmbuild/SPECS/oofalse.spec
	@cp ~/rpmbuild/RPMS/x86_64/oofalse-$(VERSION)*.rpm dist/
	@echo "built dist RPM package"

package-arch: $(BIN)
	@mkdir -p dist/arch-pkg/usr/bin
	@cp $(BIN) dist/arch-pkg/usr/bin/oofalse
	@chmod 0755 dist/arch-pkg/usr/bin/oofalse
	@cp uninstall.sh dist/arch-pkg/usr/bin/oofalse-uninstall
	@chmod 0755 dist/arch-pkg/usr/bin/oofalse-uninstall
	@printf "pkgname = oofalse\npkgbase = oofalse\npkgver = $(VERSION)-1\npkgdesc = Sovereign POSIX false utility and deterministic exit code analyzer in pure openOODA.\nurl = https://github.com/openOODA-tools/oofalse\nbuilddate = $$(date +%s)\npackager = openOODA-tools <ops@openooda.org>\nsize = $$(stat -c %s $(BIN))\narch = x86_64\nlicense = Apache-2.0\ndepend = glibc\nprovides = oofalse\n" > dist/arch-pkg/.PKGINFO
	@tar --zstd -cf dist/oofalse-$(VERSION)-1-x86_64.pkg.tar.zst -C dist/arch-pkg .PKGINFO usr
	@rm -rf dist/arch-pkg
	@bash -n packaging/arch/PKGBUILD
	@cp packaging/arch/PKGBUILD packaging/PKGBUILD
	@echo "built dist/oofalse-$(VERSION)-1-x86_64.pkg.tar.zst and validated PKGBUILD"

package: package-deb package-rpm package-arch
	@cd dist && sha256sum oofalse* > checksums.txt 2>/dev/null || true
	@echo "built all packages and dist/checksums.txt"

clean:
	@rm -rf dist .ooda-cache
	@echo "cleaned"
