#
# Cookbook Name:: mysql_community
# Recipe:: server
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

require 'shellwords'

include_recipe 'mysql_community::_set_attributes'

node['mysqld']['mysql_packages'].each { |p| package p }

# Nuke default my.cnf settings of dependent mysqld cookbook
# so they won't merge with ours
node.default['mysqld']['my.cnf'] = nil

mysqld 'default' do
  my_cnf node['mysqld']['my_cnf']
end

hosts = %w(localhost 127.0.0.1 ::1)
hosts << '%' if node['mysqld']['allow_remote_root'] == true
hosts.concat node['mysqld']['root_host_acl'] if node['mysqld']['root_host_acl']

template '/etc/mysql_grants.sql' do
  source 'grants.sql.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(hosts: hosts)
  notifies :run, 'execute[mysql_grants]'
end

execute 'mysql_grants' do
  command %(mysql #{node['mysqld']['auth'].shellescape} < /etc/mysql_grants.sql)
  only_if %(mysql #{node['mysqld']['auth'].shellescape} -e 'SHOW DATABASES;')
  action :nothing
end
