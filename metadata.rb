# frozen_string_literal: true

name 'duo-openvpn-build'
maintainer 'Jonathan Hartman'
maintainer_email 'jonathan.hartman@tylertech.com'
license 'Apache-2.0'
description 'Builds Duo-OpenVPN packages'
long_description 'Builds Duo-OpenVPN packages'
version '0.1.0'
chef_version '~> 14.0'

source_url 'https://github.com/socrata-platform/duo-openvpn-build'
issues_url 'https://github.com/socrata-platform/duo-openvpn-build/issues'

depends 'yum-epel', '~> 3.3'

supports 'ubuntu'
supports 'redhat', '>= 7.0'
supports 'centos', '>= 7.0'
supports 'scientific', '>= 7.0'
