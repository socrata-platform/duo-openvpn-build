# Encoding: UTF-8
#
# FPM Recipe:: duo-openvpn
#
# Copyright 2016, Socrata, Inc.
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
require 'fpm/cookery/recipe'

# A FPM Cookery recipe for the Duo-OpenVPN plugin
#
# @author Jonathan Hartman <jonathan.hartman@socrata.com>
class DuoOpenvpn < FPM::Cookery::Recipe
  name 'duo-openvpn'

  version ENV['BUILD_VERSION']
  revision ENV['BUILD_REVISION']

  description 'The Duo plugin for OpenVPN'
  homepage 'https://github.com/duosecurity/duo_openvpn'
  source 'https://github.com/duosecurity/duo_openvpn', with: :git

  maintainer 'Jonathan Hartman <jonathan.hartman@socrata.com>'
  vendor 'Socrata, Inc.'

  license 'Apache, version 2.0'

  build_deps = %w(git python)
  deps = %w(python)

  platforms [:debian, :ubuntu] do
    build_depends build_deps
    depends deps
  end

  platforms [:redhat, :centos, :scientific] do
    build_depends build_deps + %w(rpm-build)
    depends deps
  end

  # A set of patches of the structure:
  #
  #   {
  #     'file_to_patch' => {
  #       'string_to_patch' => 'replacement_string'
  #     }
  #   }
  #
  REPLACE_PATCHES = {
    'Makefile' => {
      '/opt/duo' => '/usr',
      'duo_openvpn.py https_wrapper.py -m 755 $(DESTDIR)$(PREFIX)' =>
        "duo_openvpn.py -m 755 $(DESTDIR)$(PREFIX)/lib/openvpn/plugins\n\t" \
          'install -c https_wrapper.py -m 755 $(DESTDIR)$(PREFIX)/lib/' \
          'openvpn/plugins/duo_openvpn'
    },
    'duo_openvpn.py' => {
      'from https_wrapper import CertValidatingHTTPSConnection' =>
        'from duo_openvpn import https_wrapper',
      'conn = CertValidatingHTTPSConnection(' =>
        'conn = https_wrapper.CertValidatingHTTPSConnection('
    }
  }.freeze

  #
  # A set of patches of the structure:
  #
  #   {
  #     'file_to_patch' => {
  #       'string_to_patch' => 'patch_to_append_to_string'
  #     }
  #   }
  #
  APPEND_PATCHES = {
    'Makefile' => {
      'mkdir -p $(DESTDIR)$(PREFIX)' => '/lib/openvpn/plugins/duo_openvpn',
      'duo_openvpn.so -m 755 $(DESTDIR)$(PREFIX)' => '/lib/openvpn/plugins',
      'ca_certs.pem -m 644 $(DESTDIR)$(PREFIX)' =>
        '/lib/openvpn/plugins/duo_openvpn'
    }
  }.freeze

  #
  # Compile the plugin.
  #
  def build
    REPLACE_PATCHES.each do |f, patches|
      inline_replace(f) { |s| patches.each { |k, v| s.gsub!(k, v) } }
    end
    APPEND_PATCHES.each do |f, patches|
      inline_replace(f) { |s| patches.each { |k, v| s.gsub!(k, "#{k}#{v}") } }
    end
    make
  end

  #
  # Make install.
  #
  def install
    make :install, DESTDIR: destdir
    f = File.open("#{destdir}/usr/lib/openvpn/plugins/duo_openvpn/__init__.py",
                  'w')
    f.write("__version__ = \"#{version}\"")
    f.close
    safesystem("python -m compileall #{destdir}/usr/lib/openvpn/plugins")
  end
end
