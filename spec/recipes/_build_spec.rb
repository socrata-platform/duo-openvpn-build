# frozen_string_literal: true

require_relative '../spec_helper'

describe 'duo-openvpn-build::_build' do
  default_attributes['duo_openvpn_build']['version'] = '1.2.3'
  default_attributes['duo_openvpn_build']['revision'] = 3

  shared_examples_for 'any platform' do
    it { is_expected.to remove_package('duo-openvpn') }
    it { is_expected.to install_build_essential('') }

    %w[git python openvpn].each do |p|
      it { is_expected.to install_package(p) }
    end

    it { is_expected.to install_chef_gem('fpm-cookery') }
    it { is_expected.to create_remote_directory('/tmp/fpm-recipes') }

    it do
      is_expected.to run_bash('Run the FPM cook').with(
        cwd: '/tmp/fpm-recipes/duo-openvpn',
        environment: {
          'BUILD_VERSION' => '1.2.3',
          'BUILD_REVISION' => '3'
        },
        code: <<-CODE.gsub(/^ {10}/, '')
          BIN=/opt/chef/embedded/bin/fpm-cook
          $BIN clean
          $BIN package
        CODE
      )
    end
  end

  context 'a Ubuntu platform' do
    platform 'ubuntu'

    it_behaves_like 'any platform'

    it { is_expected.to periodic_apt_update('default') }
    it { is_expected.to_not include_recipe('yum-epel') }
  end

  context 'a CentOS platform' do
    platform 'centos'

    it_behaves_like 'any platform'

    it { is_expected.to include_recipe('yum-epel') }
    it { is_expected.to_not periodic_apt_update('default') }
    it { is_expected.to install_package('rpm-build') }
  end
end
