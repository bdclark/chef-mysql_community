require 'serverspec'

set :backend, :exec

describe port(3306) do
  it { should be_listening }
end

describe command('mysql --version') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(/Distrib 5.6/) }
end
