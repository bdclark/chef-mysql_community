#
# Cookbook Name:: mysql_community
# Recipe:: client
#
# Copyright 2015 Brian Clark
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

version = node['mysqld']['version']

node.default['mysqld']['client_packages'] = value_for_platform_family(
  'rhel' => %w(mysql-community-client mysql-community-devel),
  'debian' => ["mysql-client-#{version}", 'libmysqlclient-dev']
)

if platform_family?('rhel')
  include_recipe "yum-mysql-community::mysql#{version.gsub('.', '')}"
end

node['mysqld']['client_packages'].each { |p| package p }
