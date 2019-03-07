# Generated from generate_csr-0.0.1.gem by gem2rpm -*- rpm-spec -*-
%global gem_name generate_csr

Name: rubygem-%{gem_name}
Version: 0.0.1
Release: 1%{?dist}
Summary: CSR generation
License: GPL-2.0
Source0: %{gem_name}-%{version}.gem
BuildRequires: ruby(release)
BuildRequires: rubygems-devel
BuildRequires: ruby
# BuildRequires: rubygem(mail)
# BuildRequires: rubygem(openssl)
# BuildRequires: rubygem(io/console)
BuildArch: noarch

%description
Generates a CSR and encrypted private key for SSL creation.


%package doc
Summary: Documentation for %{name}
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
%setup -q -n %{gem_name}-%{version}

%build
# Create the gem as gem install only works on a gem file
gem build ../%{gem_name}-%{version}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/



%check
pushd .%{gem_instdir}
# Run the test suite.
popd

%files
%dir %{gem_instdir}
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}

%files doc
%doc %{gem_docdir}


%changelog
* Mon Feb 25 2019 Shaun Rutherford <srutherford@blizzard.com> - 0.0.1-1
- Initial package
