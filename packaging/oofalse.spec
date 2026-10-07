Name:           oofalse
Version:        0.1.0
Release:        1%{?dist}
Summary:        Instant zero-byte binary returning exit status 1 without runtime overhead.
License:        ASL 2.0
URL:            https://github.com/openOODA-tools/oofalse
Source0:        oofalse-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofalse is a sovereign, capability-bounded NO-OP FAILURE written
in pure openOODA, featuring zero ambient authority, oote color themes,
and an MCP stdio server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofalse
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofalse-uninstall

%files
/usr/bin/oofalse
/usr/bin/oofalse-uninstall

%changelog
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
