# Encoding: UTF-8

require_relative '../spec_helper'

describe 'duo-openvpn-build::_build' do
  let(:version) { '1.2.3' }
  let(:revision) { 3 }
  let(:platform) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      node.normal['duo_openvpn_build']['version'] = version
      node.normal['duo_openvpn_build']['revision'] = revision
    end
  end
  let(:converge) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    it 'removes any currently installed duo-openvpn package' do
      expect(chef_run).to remove_package('duo-openvpn')
    end

    it 'includes build-essential' do
      expect(chef_run).to include_recipe('build-essential')
    end

    %w(git python).each do |p|
      it "installs #{p}" do
        expect(chef_run).to install_package(p)
      end
    end

    it 'installs FPM Cookery' do
      expect(chef_run).to install_chef_gem('fpm-cookery')
        .with(compile_time: false)
    end

    it 'syncs the FPM Cookery project directory' do
      expect(chef_run).to create_remote_directory('/tmp/fpm-recipes')
    end

    it 'runs fpm-cook' do
      expect(chef_run).to run_bash('Run the FPM cook').with(
        cwd: '/tmp/fpm-recipes/duo-openvpn',
        environment: {
          'BUILD_VERSION' => '1.2.3',
          'BUILD_REVISION' => '3'
        },
        code: <<-EOH.gsub(/^ {10}/, '')
          BIN=/opt/chef/embedded/bin/fpm-cook
          $BIN clean
          $BIN package
        EOH
      )
    end
  end

  shared_examples_for 'a Ubuntu platform' do
    it 'ensures the APT cache is refreshed' do
      expect(chef_run).to periodic_apt_update('default')
    end
  end

  shared_examples_for 'a CentOS platform' do
    it 'does not run the APT recipe' do
      expect(chef_run).to_not include_recipe('apt')
    end

    it 'installs rpm-build' do
      expect(chef_run).to install_package('rpm-build')
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'
    it_behaves_like 'a Ubuntu platform'
  end

  context 'CentOS 7.0' do
    let(:platform) { { platform: 'centos', version: '7.0' } }
    cached(:chef_run) { converge }

    it_behaves_like 'any platform'
    it_behaves_like 'a CentOS platform'
  end
end
