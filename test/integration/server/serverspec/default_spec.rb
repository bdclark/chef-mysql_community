require 'serverspec'

set :backend, :exec

describe port(3306) do
  it { should be_listening }
end

describe command('mysql --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.6/) }
end

case os[:family]
when 'ubuntu'
  rotate_file = 'mysql-server'
  rotate_auth = 'AUTH="--defaults-file=/etc/mysql/debian.cnf"'
when 'redhat'
  rotate_file = 'mysql'
  rotate_auth = 'AUTH="--defaults-file=/root/.my.cnf"'
end

if os[:family] == 'redhat'
  describe file('/root/.my.cnf') do
    it { should be_file }
    its(:content) { should match(/password = ilikerandompasswords/) }
  end
end

describe file("/etc/logrotate.d/#{rotate_file}") do
  it { should be_file }
  its(:content) { should match (rotate_auth)}
end
