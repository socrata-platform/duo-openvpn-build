# Encoding: UTF-8

require_relative '../spec_helper'

describe 'duo-openvpn::app' do
  describe package('duo-openvpn') do
    it 'is installed' do
      expect(subject).to be_installed
    end
  end

  %w(
    /etc/openvpn/duo_openvpn.ini
    /usr/lib/openvpn/plugins/duo_openvpn.py
  ).each do |f|
    describe file(f) do
      it 'exists' do
        expect(subject).to be_file
      end
    end
  end
end
