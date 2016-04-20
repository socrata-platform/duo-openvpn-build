# Encoding: UTF-8
#
# Cookbook Name:: duo-openvpn-build
# Recipe:: default
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

DuoOpenvpnBuild::Helpers.configure!(
  token: node['duo_openvpn_build']['packagecloud_token'],
  node: node,
  version: node['duo_openvpn_build']['version'],
  revision: node['duo_openvpn_build']['revision']
)

include_recipe "#{cookbook_name}::_build"
include_recipe "#{cookbook_name}::_verify"
include_recipe "#{cookbook_name}::_deploy"
