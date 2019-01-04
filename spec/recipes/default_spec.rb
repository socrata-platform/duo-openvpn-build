# frozen_string_literal: true

require_relative '../spec_helper'

describe 'duo-openvpn-build::default' do
  platform 'ubuntu'

  before do
    allow(DuoOpenvpnBuild::Helpers).to receive(:package_file)
      .and_return('/tmp/do.pkg')
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{duo-openvpn-build/libraries/helpers\.rb}).and_return(true)
  end

  %w[_build _verify _deploy].each do |r|
    it { is_expected.to include_recipe("duo-openvpn-build::#{r}") }
  end
end
