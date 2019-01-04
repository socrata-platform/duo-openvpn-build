# frozen_string_literal: true

require_relative '../spec_helper'

describe 'duo-openvpn-build::_deploy' do
  platform 'ubuntu'

  shared_examples_for 'any attribute set' do
    it { is_expected.to install_chef_gem('packagecloud-ruby') }
  end

  context 'all default attributes' do
    it_behaves_like 'any attribute set'

    it { is_expected.to_not run_ruby_block('Push artifacts to PackageCloud') }
  end

  context 'an overridden artifact publishing attribute' do
    default_attributes['duo_openvpn_build']['publish_artifacts'] = true

    it_behaves_like 'any attribute set'

    it { is_expected.to run_ruby_block('Push artifacts to PackageCloud') }
  end
end
