Name:           oofalse
Version:        0.2.0
Release:        1%{?dist}
Summary:        Sovereign POSIX false utility and deterministic exit code analyzer
License:        Apache-2.0
URL:            https://github.com/openOODA-tools/oofalse
Source0:        oofalse-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofalse is a sovereign, capability-bounded NO-OP FAILURE utility written
in pure openOODA, featuring zero ambient authority, exit code diagnostics,
pipeline simulation, and a streaming Model Context Protocol (MCP) server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofalse
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofalse-uninstall

%files
/usr/bin/oofalse
/usr/bin/oofalse-uninstall

%changelog
* Thu Oct 08 2026 openOODA-tools <ops@openooda.org> - 0.2.0-1
- Elevate to sovereign pure openOODA v0.2.0 with POSIX exit semantics and streaming MCP
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
