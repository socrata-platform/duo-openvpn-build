# Encoding: UTF-8

require_relative '../spec_helper'

describe 'duo-openvpn::app' do
  describe package('duo-openvpn') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  %w(
    /usr/lib/openvpn/plugins/duo_openvpn/ca_certs.pem
    /usr/lib/openvpn/plugins/duo_openvpn/https_wrapper.py
    /usr/lib/openvpn/plugins/duo_openvpn.py
    /usr/lib/openvpn/plugins/duo_openvpn.so
  ).each do |f|
    describe file(f) do
      it 'exists' do
        expect(subject).to be_file
      end
    end
  end
end
