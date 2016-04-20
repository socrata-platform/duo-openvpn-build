# Encoding: UTF-8

require 'packagecloud'
require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe DuoOpenvpnBuild::Helpers do
  describe '.configure!' do
    let(:config) do
      { token: 'abc123', node: 'anode', version: '1.2.3', revision: 4 }
    end
    let(:configured_class) { described_class.configure!(config) }

    it 'saves the PackageCloud token' do
      expect(configured_class.token).to eq('abc123')
    end

    it 'saves the node object' do
      expect(configured_class.node).to eq('anode')
    end

    it 'saves the version' do
      expect(configured_class.version).to eq('1.2.3')
    end

    it 'saves the revision' do
      expect(configured_class.revision).to eq(4)
    end
  end

  describe '.push_package!' do
    let(:package_file) { 'testpkgfile' }
    let(:distro_id) { 'testdistroid' }
    let(:open) { 'testopen' }
    let(:package) { 'testpkg' }
    let(:client) { double }

    before(:each) do
      allow(described_class).to receive(:package_file).and_return(package_file)
      allow(described_class).to receive(:distro_id).and_return(distro_id)
      allow(Packagecloud::Package).to receive(:new).with(file: package_file)
        .and_return(package)
      allow(described_class).to receive(:client).and_return(client)
    end

    it 'uploads the proper package artifact' do
      expect(client).to receive(:put_package)
        .with('duo-openvpn', package, distro_id)
      described_class.push_package!
    end
  end

  describe '.package_file' do
    let(:platform) { nil }
    let(:node) { Fauxhai.mock(platform).data }
    let(:version) { '1.2.3' }
    let(:revision) { 4 }

    before(:each) do
      %i(version revision node).each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
    end

    shared_examples_for 'a debian platform' do
      it 'returns a Debian-style package path' do
        expect(described_class.package_file).to eq(
          '/tmp/fpm-recipes/duo-openvpn/pkg/duo-openvpn_1.2.3-4_amd64.deb'
        )
      end
    end

    shared_examples_for 'a rhel platform' do
      it 'returns a RHEL-style package path' do
        expect(described_class.package_file).to eq(
          '/tmp/fpm-recipes/duo-openvpn/pkg/duo-openvpn-1.2.3-4.x86_64.rpm'
        )
      end
    end

    context 'Ubuntu 14.04' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it_behaves_like 'a debian platform'
    end

    context 'Debian 8.2' do
      let(:platform) { { platform: 'debian', version: '8.2' } }

      it_behaves_like 'a debian platform'
    end

    context 'RHEL 7.1' do
      let(:platform) { { platform: 'redhat', version: '7.1' } }

      it_behaves_like 'a rhel platform'
    end

    context 'CentOS 7.0' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it_behaves_like 'a rhel platform'
    end
  end

  describe '.distro_id' do
    let(:platform) { nil }
    let(:node) { Fauxhai.mock(platform).data }

    before(:each) do
      allow(described_class).to receive(:node).and_return(node)
    end

    context 'Ubuntu 14.04' do
      let(:platform) { { platform: 'ubuntu', version: '14.04' } }

      it 'returns the correct distro ID' do
        expect(described_class.distro_id).to eq('ubuntu/trusty')
      end
    end

    context 'Debian 8.2' do
      let(:platform) { { platform: 'debian', version: '8.2' } }

      it 'returns the correct distro ID' do
        expect(described_class.distro_id).to eq('debian/jessie')
      end
    end

    context 'RHEL 7.1' do
      let(:platform) { { platform: 'redhat', version: '7.1' } }

      it 'returns the correct distro ID' do
        expect(described_class.distro_id).to eq('el/7')
      end
    end

    context 'CentOS 7.0' do
      let(:platform) { { platform: 'centos', version: '7.0' } }

      it 'returns the correct distro ID' do
        expect(described_class.distro_id).to eq('el/7')
      end
    end
  end

  describe '.revision' do
    let(:token) { nil }
    let(:relevant_packages) { [] }
    let(:version) { '1.2.3' }

    before(:each) do
      described_class.configure!
      %i(token relevant_packages version).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    context 'no configured PackageCloud token' do
      let(:token) { nil }

      it 'returns 1' do
        expect(described_class.revision).to eq(1)
      end
    end

    context 'an empty list of packages' do
      let(:token) { 'token' }
      let(:relevant_packages) { [] }

      it 'returns 1' do
        expect(described_class.revision).to eq(1)
      end
    end

    context 'a populated list of packages' do
      let(:token) { 'token' }
      let(:relevant_packages) do
        [
          { 'version' => '1.2.3', 'release' => '1' },
          { 'version' => '1.2.3', 'release' => '2' },
          { 'version' => '1.2.3', 'release' => '3' }
        ]
      end

      it 'returns 1 greater than the current revision' do
        expect(described_class.revision).to eq(4)
      end
    end
  end

  describe '.relevant_packages' do
    let(:packages) { [] }
    let(:version) { '1.2.3' }

    before(:each) do
      described_class.configure!
      %i(packages version).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    context 'an empty list of packages' do
      let(:packages) { [] }

      it 'returns an empty array' do
        expect(described_class.relevant_packages).to eq([])
      end
    end

    context 'a populated list of packages' do
      let(:packages) do
        [
          { 'version' => '0.1.2', 'release' => '6' },
          { 'version' => '1.2.3', 'release' => '1' },
          { 'version' => '1.2.3', 'release' => '2' },
          { 'version' => '1.2.3', 'release' => '3' },
          { 'version' => '4.5.6', 'release' => '7' }
        ]
      end

      it 'returns the subset of packages that match our version' do
        expected = [
          { 'version' => '1.2.3', 'release' => '1' },
          { 'version' => '1.2.3', 'release' => '2' },
          { 'version' => '1.2.3', 'release' => '3' }
        ]
        expect(described_class.relevant_packages).to eq(expected)
      end
    end
  end

  describe '.version' do
    let(:token) { 'abc123' }
    let(:packages) do
      [
        { 'version' => '4.3.2', 'release' => '3' },
        { 'version' => '1.0.0', 'release' => '4' },
        { 'version' => '9.3.6', 'release' => '1' },
        { 'version' => '3.3.7', 'release' => '2' }
      ]
    end

    before(:each) do
      described_class.configure!
      allow(described_class).to receive(:token).and_return(token)
      allow(described_class).to receive(:packages).and_return(packages)
    end

    context 'a configured token and populated package list' do
      it 'returns the next minor version' do
        expect(described_class.version).to eq('9.4.0')
      end
    end

    context 'no configured PackageCloud token' do
      let(:token) { nil }

      it 'returns 0.1.0' do
        expect(described_class.version).to eq('0.1.0')
      end
    end

    context 'a nil list of packages' do
      let(:packages) { nil }

      it 'returns 0.1.0' do
        expect(described_class.version).to eq('0.1.0')
      end
    end

    context 'an empty list of packages' do
      let(:packages) { [] }

      it 'returns 0.1.0' do
        expect(described_class.version).to eq('0.1.0')
      end
    end
  end

  describe '.packages' do
    let(:packages) do
      [
        { 'version' => '1.0.0', 'release' => '3' },
        { 'version' => '1.0.0', 'release' => '4' },
        { 'version' => '1.2.3', 'release' => '1' },
        { 'version' => '1.2.3', 'release' => '2' }
      ]
    end
    let(:client) { double(list_packages: double(response: packages)) }
    let(:version) { '1.2.3' }

    before(:each) do
      %i(client version).each do |i|
        allow(described_class).to receive(i).and_return(send(i))
      end
    end

    it 'returns the package list' do
      expect(described_class.packages).to eq(packages)
    end
  end

  describe '.node' do
    let(:system) { double }

    before(:each) do
      allow(Ohai::System).to receive(:new).and_return(system)
    end

    it 'loads Ohai plugin data' do
      expect(system).to receive(:all_plugins)
      expect(described_class.node).to eq(system)
    end
  end

  describe '.client' do
    let(:token) { 'abc123' }
    let(:credentials) { 'somecreds' }
    let(:client) { 'someclient' }

    before(:each) do
      allow(described_class).to receive(:token).and_return(token)
      allow(Packagecloud::Credentials).to receive(:new)
        .with('socrata-platform', token).and_return(credentials)
      allow(Packagecloud::Client).to receive(:new).with(credentials)
        .and_return(client)
    end

    it 'returns a PackageCloud client object' do
      expect(described_class.client).to eq('someclient')
    end
  end
end
