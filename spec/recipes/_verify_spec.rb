# frozen_string_literal: true

require_relative '../spec_helper'

describe 'duo-openvpn-build::_verify' do
  before do
    allow(DuoOpenvpnBuild::Helpers).to receive(:package_file)
      .and_return('/tmp/do.pkg')
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{duo-openvpn-build/libraries/helpers\.rb}).and_return(true)
  end

  shared_examples_for 'any platform' do
    it { is_expected.to install_chef_gem('serverspec') }
    it { is_expected.to create_remote_directory(File.expand_path('/tmp/spec')) }

    it do
      is_expected.to run_execute(
        '/opt/chef/embedded/bin/rspec */*_spec.rb -f d'
      ).with(cwd: File.expand_path('/tmp/spec'))
    end
  end

  context 'a Ubuntu platform' do
    platform 'ubuntu'

    it_behaves_like 'any platform'

    it do
      is_expected.to install_dpkg_package('duo-openvpn')
        .with(package_name: '/tmp/do.pkg')
    end
  end

  context 'a CentOS platform' do
    platform 'centos'

    it_behaves_like 'any platform'

    it do
      is_expected.to install_rpm_package('duo-openvpn')
        .with(package_name: '/tmp/do.pkg')
    end
  end
end
