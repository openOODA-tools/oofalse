# oofalse: Sovereign NO-OP FAILURE

<div align="center">

```
================================================================================
                                oofalse
               Sovereign openOODA NO-OP FAILURE
================================================================================
```

**Sovereign NO-OP FAILURE & Deterministic Exit Status Analyzer**  
*Instant zero-byte binary returning exit status 1 without runtime overhead.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oofalse/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oofalse-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oofalse/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oofalse/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oofalse-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oofalse/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: oofalse [options] [ARGUMENTS]...

Sovereign NO-OP FAILURE utility with deterministic exit code semantics.
When invoked without diagnostic options, executes zero ops and exits with status 1.

Options:
  -h, --help           display this help and exit (exit 0)
  -v, --version        output version information and exit (exit 0)
  -c, --code <CODE>    exit with custom status code (default: 1)
  -m, --message <MSG>  write failure explanation to stderr before exiting
  -e, --explain        print POSIX exit status code reference table
  -j, --json           output failure metadata as JSON to stdout
  -D, --demo           run interactive failure and pipeline showcase
      --test           execute internal subsystem verification suite
      --mcp            run as Model Context Protocol JSON-RPC stdio server
```

---

## 3. Model Context Protocol (MCP)

When invoked with `--mcp`, `oofalse` runs a JSON-RPC 2.0 stdio server providing structured tools for AI coding agents:

* `false_eval`: Evaluates failure exit status and returns formatted diagnostic metadata.
* `false_exit_code`: Looks up POSIX exit code meaning, failure domain, and fatal signal mapping (128+N).
* `false_assert`: Validates that a condition is false; verifies failure expectations.
* `false_simulate`: Simulates shell pipeline failure propagation under `errexit`, `pipefail`, and `trap ERR`.
* `false_demo`: Runs interactive failure semantics and signal offset showcase.

```bash
oofalse --mcp
```

---

## 4. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 5. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
