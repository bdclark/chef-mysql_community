# rubocop:disable Metrics/LineLength

default['mysqld']['version'] = nil

default['mysqld']['allow_remote_root'] = false
default['mysqld']['root_host_acl'] = []

default['mysqld']['my_cnf']['mysqld']['port'] = 3306
default['mysqld']['my_cnf']['mysqld']['bind-address'] = '127.0.0.1'
default['mysqld']['my_cnf']['mysqld']['user'] = 'mysql'
default['mysqld']['my_cnf']['mysqld']['datadir'] = '/var/lib/mysql'
default['mysqld']['my_cnf']['mysqld']['pid-file'] = '/var/run/mysqld/mysqld.pid'
default['mysqld']['my_cnf']['mysqld']['symbolic-links'] = 0

default['mysqld']['my_cnf']['client']['port'] = node['mysqld']['my_cnf']['mysqld']['port']
default['mysqld']['my_cnf']['client']['socket'] = node['mysqld']['my_cnf']['mysqld']['socket']

case node['platform_family']
when 'rhel'
  default['mysqld']['my_cnf']['mysqld']['socket'] = '/var/lib/mysql/mysql.sock'
  default['mysqld']['my_cnf']['mysqld']['log-error'] = '/var/log/mysqld.log'
  default['mysqld']['my_cnf']['mysqld']['sql_mode'] = 'NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES'

  default['mysqld']['my_cnf']['mysqld_safe']['pid-file'] = '/var/run/mysqld/mysqld.pid'
  default['mysqld']['my_cnf']['mysqld_safe']['log-error'] = '/var/log/mysqld.log'
when 'debian'
  default['mysqld']['my_cnf']['mysqld']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mysqld']['my_cnf']['mysqld']['log-error'] = '/var/log/mysql/error.log'

  default['mysqld']['my_cnf']['mysqld_safe']['socket'] = '/var/run/mysqld/mysqld.sock'
  default['mysqld']['my_cnf']['mysqld_safe']['nice'] = 0

  default['mysqld']['my_cnf']['mysqld']['tmpdir'] = '/tmp'
  default['mysqld']['my_cnf']['mysqld']['skip-external-locking'] = true
  default['mysqld']['my_cnf']['mysqld']['key_buffer'] = '16M'
  default['mysqld']['my_cnf']['mysqld']['max_allowed_packet'] = '16M'
  default['mysqld']['my_cnf']['mysqld']['thread_stack'] = '192K'
  default['mysqld']['my_cnf']['mysqld']['thread_cache_size'] = 8
  default['mysqld']['my_cnf']['mysqld']['myisam-recover'] = 'BACKUP'
  default['mysqld']['my_cnf']['mysqld']['query_cache_limit'] = '1M'
  default['mysqld']['my_cnf']['mysqld']['query_cache_size'] = '16M'
  default['mysqld']['my_cnf']['mysqld']['expire_logs_days'] = 10
  default['mysqld']['my_cnf']['mysqld']['max_binlog_size'] = '100M'
  default['mysqld']['my_cnf']['mysqld']['innodb_file_per_table'] = 1
  default['mysqld']['my_cnf']['mysqld']['innodb_thread_concurrency'] = 0
  default['mysqld']['my_cnf']['mysqld']['innodb_flush_log_at_trx_commit'] = 1
  default['mysqld']['my_cnf']['mysqld']['innodb_additional_mem_pool_size'] = '16M'
  default['mysqld']['my_cnf']['mysqld']['innodb_log_buffer_size'] = '4M'

  default['mysqld']['my_cnf']['mysqldump']['quick'] = true
  default['mysqld']['my_cnf']['mysqldump']['quote-names'] = true
  default['mysqld']['my_cnf']['mysqldump']['max_allowed_packet'] = '16M'

  default['mysqld']['my_cnf']['isamchk']['key_buffer'] = '16M'
end
