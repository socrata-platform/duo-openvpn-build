# Encoding: UTF-8

require_relative '../spec_helper'

describe 'duo-openvpn-build::_verify' do
  let(:platform) { nil }
  let(:package_file) { '/tmp/package.pkg' }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  let(:converge) { runner.converge(described_recipe) }

  before(:each) do
    allow(DuoOpenvpnBuild::Helpers).to receive(:package_file)
      .and_return('/tmp/do.pkg')
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{duo-openvpn-build/libraries/helpers\.rb}).and_return(true)
  end

  shared_examples_for 'any platform' do
    it 'installs the serverspec gem' do
      expect(chef_run).to install_chef_gem('serverspec')
        .with(compile_time: false)
    end

    it 'copies over the spec directory' do
      expect(chef_run).to create_remote_directory(File.expand_path('/tmp/spec'))
    end

    it 'runs the ServerSpec tests' do
      expect(chef_run).to run_execute(
        '/opt/chef/embedded/bin/rspec */*_spec.rb -f d'
      ).with(cwd: File.expand_path('/tmp/spec'))
    end
  end

  context 'Ubuntu' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'uses the correct package resource' do
      expect(chef_run).to install_dpkg_package('duo-openvpn')
        .with(package_name: '/tmp/do.pkg')
    end
  end

  context 'CentOS' do
    let(:platform) { { platform: 'centos', version: '7.0' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'

    it 'uses the correct package resource' do
      expect(chef_run).to install_rpm_package('duo-openvpn')
        .with(package_name: '/tmp/do.pkg')
    end
  end
end
