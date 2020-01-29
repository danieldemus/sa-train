Name:           sa-train
Version:        1.0.1        
Release:        1%{?dist}
Summary:        Run sa-learn on all mailbox folders for users that are members of the certain group.

License:        GPL-v3
URL:            https://github.com/danieldemus/sa-train
Source0:        https://github.com/danieldemus/sa-train/archive/%{version}.tar.gz

Requires:       bash sudo coreutils findutils spamassassin
BuildArch:      noarch

%description
A bash script and systemd setup that run sa-learn on all mailbox folders for users that
are members of the satrain group.

It is assumed that read mails in a Spam folder in the root of a user's maildir has spam,
while everthing else is ham. A directory called SpamSuspect is assumed to contain mail
that needs to be manually categorised by being moved into Spam or another folder. 

All the specific names can be configured.

%prep
%setup -c sa-learn-%{version}

%build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}%{_bindir} \
         %{buildroot}%{_sysconfdir}/ \
         %{buildroot}%{_unitdir} \
         %{buildroot}%{_pkgdocdir} \
         %{buildroot}%{_sysusersdir}

cd sa-train-%{version}
install sa-train.sh %{buildroot}%{_bindir}/sa-train.sh
install sa-train-user.sh %{buildroot}%{_bindir}/sa-train-user.sh

#README
install -m644 README.md %{buildroot}%{_pkgdocdir}
install -m644 LICENSE %{buildroot}%{_pkgdocdir}

#Config file
install -m644 sa-train.conf %{buildroot}%{_sysconfdir}/sa-train.conf

# Systemd
install -m644 sa-train.service %{buildroot}%{_unitdir}/%{name}.service
install -m644 sa-train.timer %{buildroot}%{_unitdir}/%{name}.timer
install -m644 sa-train.target %{buildroot}%{_unitdir}/%{name}.target

#install systemd sysuser file
install -Dpm 644 sa-train-group.conf %{buildroot}%{_sysusersdir}/

%post
%systemd_post sa-learn.timer

%preun
%systemd_preun sa-learn.timer

%postun
%systemd_postun_with_restart sa-learn.timer

%files
%doc %{_pkgdocdir}/README.md
%license %{_pkgdocdir}/LICENSE
%defattr(0644,root,root,0755)
%config(noreplace) %{_sysconfdir}/sa-train.conf

%defattr(-,root,root,-)
%{_sysusersdir}/sa-train-group.conf
%{_bindir}/sa-train.sh
%{_bindir}/sa-train-user.sh
%{_unitdir}/sa-train.service
%{_unitdir}/sa-train.target
%{_unitdir}/sa-train.timer

%changelog
* Sat Jan 18 2020 Daniel Demus <dde@nine.dk>
- Initial release
