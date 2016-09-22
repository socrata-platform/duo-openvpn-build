# Encoding: UTF-8
#
# Cookbook Name:: duo-openvpn-build
# Recipe:: _build
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

package 'duo-openvpn' do
  action :remove
end

apt_update 'default' if node['platform_family'] == 'debian'
include_recipe 'yum-epel' if node['platform_family'] == 'rhel'
include_recipe 'build-essential'

deps = %w(git python openvpn)
deps += %w(rpm-build) if node['platform_family'] == 'rhel'
deps.each { |d| package d }

chef_gem 'fpm-cookery' do
  compile_time false
end

remote_directory '/tmp/fpm-recipes'

bash 'Run the FPM cook' do
  cwd '/tmp/fpm-recipes/duo-openvpn'
  environment(
    'BUILD_VERSION' => node['duo_openvpn_build']['version'],
    'BUILD_REVISION' => node['duo_openvpn_build']['revision'].to_s
  )
  code <<-EOH.gsub(/^ {4}/, '')
    BIN=/opt/chef/embedded/bin/fpm-cook
    $BIN clean
    $BIN package
  EOH
end
