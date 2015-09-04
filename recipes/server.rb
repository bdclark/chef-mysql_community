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

version = node['mysqld']['version']

node.override['mysqld']['mysql_packages'] = value_for_platform_family(
  'rhel' => 'mysql-community-server',
  'debian' => "mysql-server-#{version}"
)

if platform_family?('rhel')
  include_recipe "yum-mysql-community::mysql#{version.gsub('.', '')}"
end

include_recipe 'mysqld::mysql_install'

# configure based on ['mysqld']['my.cnf'] node attributes
mysqld 'default'

password = node.run_state['mysqld']['root_password'] if node.run_state['mysqld']
password ||= node['mysqld']['root_password']

template '/root/.my.cnf' do
  source 'root.my.cnf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    password: password
  )
  not_if { node['platform_family'] == 'debian' }
end

mysqld_password 'root' do
  password password
  only_if { password }
end

log_files = []
node['mysqld']['logrotate']['files'].each do |log|
  log_files << node['mysqld']['my.cnf']['mysqld'][log]
  if node['mysqld']['my.cnf']['mysqld_safe']
    log_files << node['mysqld']['my.cnf']['mysqld_safe'][log]
  end
end
log_files.compact!.uniq!

template node['mysqld']['logrotate']['path'] do
  source 'logrotate.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    user: node['mysqld']['my.cnf']['mysqld']['user'],
    group: node['mysqld']['logrotate']['group'],
    auth: node['mysqld']['auth'],
    files: log_files
  )
end

maint_passwd = node.run_state['mysqld']['sys_maint_password'] if node.run_state['mysqld']
maint_passwd ||= node['mysqld']['sys_maint_password']

mysqld_password 'debian-sys-maint' do
  password maint_passwd
  only_if { maint_passwd }
end
