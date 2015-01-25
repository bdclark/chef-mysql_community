require 'serverspec'

set :backend, :exec

describe command('mysql --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.6/) }
end
