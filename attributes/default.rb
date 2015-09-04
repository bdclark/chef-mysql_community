
default['mysqld']['allow_remote_root'] = false
default['mysqld']['root_host_acl'] = []

default['mysqld']['version'] = value_for_platform(
  %w(centos amazon redhat fedora) => {
    'default' => '5.6'
  },
  'ubuntu' => {
    '< 14.04' => '5.5',
    'default' => '5.6'
  },
  'debian' => {
    'default' => '5.5'
  }
)

default['mysqld']['auth'] = value_for_platform(
  %w(debian ubuntu) => {
    'default' => '--defaults-file=/etc/mysql/debian.cnf'
  },
  'default' => '--defaults-file=/root/.my.cnf'
)

default['mysqld']['logrotate']['files'] = %w(log log-error slow-query-log-file)
default['mysqld']['logrotate']['path'] = value_for_platform(
  %w(debian ubuntu) => {
    'default' => '/etc/logrotate.d/mysql-server'
  },
  'default' => '/etc/logrotate.d/mysql'
)

default['mysqld']['logrotate']['group'] = value_for_platform(
  'ubuntu' => {
    'default' => 'adm'
  },
  'default' => 'mysql'
)

# my.cnf configuration, additional defaults at...
# https://github.com/chr4-cookbooks/mysqld/blob/master/attributes/defaults.rb
case node['platform_family']
when 'debian'
  default['mysqld']['my.cnf']['mysqld']['log-error'] = '/var/log/mysql/error.log'
  default['mysqld']['my.cnf']['mysqld']['slow-query-log-file'] =
    '/var/log/mysql/slow-query.log'
when 'rhel'
  default['mysqld']['my.cnf']['mysqld']['slow-query-log-file'] =
    '/var/log/mysqld-slow.log'
end
