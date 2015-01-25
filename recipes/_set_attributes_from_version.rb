#
# Cookbook Name:: mysql_community
# Recipe:: _set_attributes_from_version
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

case node['platform_family']
when 'rhel'
  version ||= '5.6'
  if %w(5.5 5.6 5.7).include? version
    include_recipe "yum-mysql-community::mysql#{version.gsub('.', '')}"
    server_packages = %w(mysql-community-server)
    client_packages = %w(mysql-community-client mysql-community-devel)
  end
when 'debian'
  case node['platform_version']
  when '12.04'
    version ||= '5.5'
    if version == '5.5'
      server_packages = %w(mysql-server-5.5)
      client_packages = %w(mysql-client-5.5 libmysqlclient-dev)
    end
  when '14.04'
    version ||= '5.6'
    if %w(5.5 5.6).include? version
      server_packages = ["mysql-server-#{version}"]
      client_packages = ["mysql-client-#{version}", 'libmysqlclient-dev']
    end
  end
end

unless server_packages && client_packages
  fail "No MySQL #{version} packages supported for this platform!"
end

node.default['mysqld']['version'] = version
node.default['mysqld']['mysql_packages'] = server_packages
node.default['mysqld']['client_packages'] = client_packages
