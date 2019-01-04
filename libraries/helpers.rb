# frozen_string_literal: true

#
# Cookbook Name:: duo-openvpn-build
# Library:: helpers
#
# Copyright 2016, Tyler Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'net/http'
require 'json'
require 'ohai'

module DuoOpenvpnBuild
  # Helper methods that are shared, to be used in both the individual builder
  # servers as well as the central instance coordinating them.
  #
  # @author Jonathan Hartman <jonathan.hartman@tylertech.com>
  class Helpers
    class << self
      attr_reader :token

      #
      # Store configuration information into class variables for later use.
      # Options that can be passed in are:
      #
      #   * token - A PackageCloud API token (required for some functions)
      #   * node - A Chef node object with platform info (will be grabbed
      #     from Ohai if not provided)
      #   * version - The version of the package to build (will be pulled from
      #     the project's GitHub repo if not provided)
      #   * revision - The revision of the package to build (will be generated
      #     based on the current repo contents if not provided)
      #
      # @param config [Hash] a set of config options
      #
      def configure!(config = {})
        @token = config[:token]
        @node = config[:node]
        @version = config[:version]
        @revision = config[:revision]
        self
      end

      #
      # Read in a package file and upload it to PackageCloud.
      #
      def push_package!
        require 'packagecloud'
        pkg = Packagecloud::Package.new(file: package_file)
        client.put_package('duo-openvpn', pkg, distro_id)
      end

      #
      # Return the platform-dependent path to the package artifact
      #
      # @return [String] a package file path
      #
      def package_file
        File.join('/tmp/fpm-recipes/duo-openvpn/pkg',
                  case node['platform_family']
                  when 'debian'
                    "duo-openvpn_#{version}-#{revision}_amd64.deb"
                  when 'rhel'
                    "duo-openvpn-#{version}-#{revision}.x86_64.rpm"
                  end)
      end

      #
      # Return the platform-dependent distro ID for use with PackageCloud.
      #
      # @return [String] a distro ID
      #
      def distro_id
        case node['platform_family']
        when 'debian'
          "#{node['platform']}/#{node['lsb']['codename']}"
        when 'rhel'
          "el/#{node['platform_version'].to_i}"
        end
      end

      #
      # If no version has yet been configured:
      #
      #   * Return 1 if there's also no PackageCloud API token
      #   * Return 1 if this version doesn't exist in PackageCloud yet
      #   * Return n + 1 where n is the most recent release
      #
      # @return [Fixnum] a revision number
      #
      def revision
        @revision ||= begin
          if token.nil? || packages.nil? || packages.empty?
            1
          else
            packages.max_by { |p| p['release'] }['release'].to_i + 1
          end
        end
      end

      #
      # Return a list of packages in PackageCloud that match the desired version
      # number.
      #
      # @return [Array<Hash>] an array of packages
      #
      def packages
        @packages ||= begin
          client.list_packages('duo-openvpn').response.select do |p|
            p['version'] == version
          end
        end
      end

      #
      # Return the source URL of a tarball of the most recent version of the
      # Duo plugin, determined based on the latest GitHub tag's tarball URL.
      #
      # @return [String] a download URL
      #
      def source_url
        @source_url ||= tag['tarball_url']
      end

      #
      # If no version has yet been configured, find the most recent release in
      # in the project's GitHub repo.
      #
      # @return [String] a version string
      #
      def version
        @version ||= tag['name']
      end

      #
      # Hit the GitHub API and find the most recent tagged version of the Duo
      # plugin, returning the hash representation of that tag. Save the tag
      # in a class variable so there's no race condition when a new version
      # is released while a build is running.
      #
      # @return [Hash] the properties for the latest tag
      #
      def tag
        @tag ||= JSON.parse(
          Net::HTTP.get(URI('https://api.github.com/repos/duosecurity/' \
                            'duo_openvpn/tags'))
        ).first
      end

      #
      # Load up Ohai and generate a node object so we know the platform
      # information needed to manage packages.
      #
      # @return [Ohai::System] platform information addressable as a hash
      #
      def node
        @node ||= begin
                    s = Ohai::System.new
                    s.all_plugins
                    s
                  end
      end

      #
      # Use the saved PackageCloud API token to authenticate with their API and
      # return a client.
      #
      # @return [Packagecloud::Client] a new client object
      #
      def client
        @client ||= begin
          require 'packagecloud'
          creds = Packagecloud::Credentials.new('socrata-platform', token)
          Packagecloud::Client.new(creds)
        end
      end
    end
  end
end
