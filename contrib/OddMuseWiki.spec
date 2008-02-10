Name: OddMuseWiki
Version: 2007.12.31
Release: 1suse
Group: Applications/Productivity
License: /opt/OddMuseWiki/doc/COPYING
Summary: Simple user-editted website (wiki)

Distribution: any perl+webserver+cgi distro
Vendor: Alex Schröder
Packager: Dr. Robert J. Meier <grandfather@sourceforge.org>
URL: http://www.oddmusewiki.org/

BuildRoot: /var/tmp/rpm-oddmusewiki-root
BuildArch: noarch
Prefix: /opt/OddMuseWiki
Prefix: /srv/www/wiki
Prefix: /srv/www/cgi-bin
Prefix: /etc/httpd/conf.d
Source0: %{name}-%{version}.tar.gz
Source1: %{name}-modules-%{version}.tar.gz
Source2: %{name}-contents-%{version}.tar.gz

Provides: wiki
Requires: perl >= 5.0.0

# Avoid automatic dependency calculation macros, as they are seldom portable.
AutoReq: no
AutoProv: no



%description
OddMuseWiki is a program to run a wiki.
A wiki can be used for communication in a team or for documentation,
when things have to be quick and easy: Content Management for everybody.

A wiki enables other people to quickly join efforts. In the office,
you can introduce new employees, distribute phone lists, store memos,
plan trips, document projects, prepare meetings,
or describe internal processes.

For many free software projects wikis have taken an important role
somewhere between manual, FAQ, IRC, and mailing lists.

OddMuseWiki is very easy to install: Simple installation, compact code,
and easy extensibility were the most important design factors.

Features

   1. Easy to install: Just copy one file into the correct directory.
   2. No dependencies on version management tools or database installation.
   3. Web server needs only Perl installed.
   4. Easy to use for users, easy to hack for programmers.
   5. Capable of multilingual sites.
   6. Unicode (UTF-8) per default.
   7. Valid HTML; CSS friendly.
   8. Caching on several levels.
   9. Easy to download.



%prep
# Record the environment variables
#                     $RPM_ARCH $RPM_OS - host configuration
#                        $RPM_OPT_FLAGS - c compile flags
#   $RPM_PACKAGE_[NAME VERSION RELEASE] - spec file fields
#                       $RPM_SOURCE_DIR - base for Source and Patch filenames
#                        $RPM_BUILD_DIR - base for setup macro filenames
#                       $RPM_BUILD_ROOT - %{BuildRoot}
#                                           modified by rpmbuild --buildroot
#                          $RPM_DOC_DIR - base for doc macro filenames
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-prep.log; fi

%setup -q -b1 -b2



%build
# Record the environment variables
#   Nomimally these are the same as for %prep
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-build.log; fi

# Nothing to build yet.



%install
# Record the environment variables
#   Nomimally these are the same as for %prep
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-install.log; fi

rm -rf "$RPM_BUILD_ROOT"
mkdir -p "$RPM_BUILD_ROOT"/opt/OddMuseWiki/cgi-bin
mkdir -p "$RPM_BUILD_ROOT"/opt/OddMuseWiki/doc
mkdir -p "$RPM_BUILD_ROOT"/opt/OddMuseWiki/etc
mkdir -p "$RPM_BUILD_ROOT"/opt/OddMuseWiki/libperl
mkdir -p "$RPM_BUILD_ROOT"/srv/www/cgi-bin
mkdir -p "$RPM_BUILD_ROOT"/srv/www/wiki
mkdir -p "$RPM_BUILD_ROOT"/etc/httpd/conf.d

install cgi-bin/wiki.pl "$RPM_BUILD_ROOT"/opt/OddMuseWiki/cgi-bin
install cgi-bin/wiki.pl "$RPM_BUILD_ROOT"/srv/www/cgi-bin
install doc/COPYING "$RPM_BUILD_ROOT"/opt/OddMuseWiki/doc
install etc/oddmusewiki.conf "$RPM_BUILD_ROOT"/opt/OddMuseWiki/etc
install libperl/current libperl/*.pl "$RPM_BUILD_ROOT"/opt/OddMuseWiki/libperl
cp -r wiki "$RPM_BUILD_ROOT"/srv/www



%clean
# Record the environment variables
#   Nomimally these are the same as for %prep
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-clean.log; fi
rm -rf "$RPM_BUILD_ROOT"



%pre
# Record local environment variables.
#   $RPM_INSTALL_PREFIX* reflect the Prefix: field(s)
#   modified by --relocate and --prefix arguments
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-pre.log; fi



%post
# Record local environment variables
#   $RPM_INSTALL_PREFIX* reflect the Prefix: field(s)
#   modified by --relocate and --prefix arguments
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-post.log; fi

# Because relocation may change configuration,
#   it cannot be symlinked into a public access site at rpmbuild -bb time.
if [ \( -d "$RPM_INSTALL_PREFIX2" -a -w "$RPM_INSTALL_PREFIX2" \) -o -w "$RPM_INSTALL_PREFIX2"/wiki.pl ]; then
  cat "$RPM_INSTALL_PREFIX0"/cgi-bin/wiki.pl |
  perl -pe 's:/opt/OddMuseWiki:'"$RPM_INSTALL_PREFIX0"':;' |
  perl -pe 's:/srv/www/wiki:'"$RPM_INSTALL_PREFIX1"':;' |
  cat > "$RPM_INSTALL_PREFIX2"/wiki.pl
fi



%preun
# Record local environment variables
#   $RPM_INSTALL_PREFIX* reflect the Prefix: field(s)
#   modified by --relocate and --prefix arguments at rpm -i time
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-preun.log; fi



%postun
# Record local environment variables
#   $RPM_INSTALL_PREFIX* reflect the Prefix: field(s)
#   modified by --relocate and --prefix arguments at rpm -i time
if [ "$RPM_DUMPENV" != "" ] ; then env | sort > /tmp/rpm-postun.log; fi



%files
# The doc, config, attr and many other macros are well documented in RPM-HOWTO
%defattr(0444,root,root)
%license
%attr(0555,root,root) /opt/OddMuseWiki
%config /opt/OddMuseWiki/etc/oddmusewiki.conf
%attr(0777,root,root) /srv/www/wiki
%attr(0555,root,root) /srv/www/cgi-bin/wiki.pl



%changelog
* Wed Jan 3 2008 Dr. Robert Meier <grandfather@sourceforge.org> 2007.12.13-1suse
- copy-and-edit from hello.rpm
