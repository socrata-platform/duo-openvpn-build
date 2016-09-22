# Encoding: UTF-8

require_relative '../spec_helper'

describe 'duo-openvpn-build::_deploy' do
  let(:platform) { { platform: 'ubuntu', version: '14.04' } }
  let(:publish_artifacts) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      unless publish_artifacts.nil?
        k = 'duo_openvpn_build'
        node.normal[k]['publish_artifacts'] = publish_artifacts
      end
    end
  end
  let(:converge) { runner.converge(described_recipe) }

  shared_examples_for 'any attributes' do
    it 'installs the packagecloud-ruby gem' do
      expect(chef_run).to install_chef_gem('packagecloud-ruby')
        .with(compile_time: false)
    end
  end

  context 'default attributes' do
    cached(:chef_run) { converge }

    it_behaves_like 'any attributes'

    it 'does not execute the artifact push' do
      expect(chef_run).to_not run_ruby_block('Push artifacts to PackageCloud')
    end
  end

  context 'artifact publishing enabled' do
    let(:publish_artifacts) { true }
    cached(:chef_run) { converge }

    it_behaves_like 'any attributes'

    it 'executes the artifact push' do
      expect(chef_run).to run_ruby_block('Push artifacts to PackageCloud')
    end
  end
end
