require_relative 'spec_helper'

describe 'mysql_community::server' do
  let(:platform) { nil }
  let(:platform_version) { nil }
  let(:version) { nil }
  let(:password) { nil }
  let(:maint_passwd) { nil }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: platform,
                             version: platform_version) do |node|
      node.set['mysqld']['version'] = version
      node.run_state = {
        'mysqld' => {
          'root_password' => password,
          'sys_maint_password' => maint_passwd
        }
      }
    end.converge(described_recipe)
  end

  context 'with rhel platform' do
    let(:platform) { 'centos' }
    let(:platform_version) { '6.5' }

    %w(5.5 5.6 5.7).each do |v|
      context "with supported version #{v}" do
        let(:version) { v }

        it "add mysql-community #{v} repo" do
          yum_recipe = "yum-mysql-community::mysql#{v.gsub('.', '')}"
          expect(chef_run).to include_recipe yum_recipe
        end
      end
    end

    context 'when version not specified' do
      it 'add mysql-community 5.6 repo' do
        expect(chef_run).to include_recipe 'yum-mysql-community::mysql56'
      end
    end

    it 'install mysql-community-server package' do
      expect(chef_run).to install_package('mysql-community-server')
    end

    it 'creates root .my.cnf' do
      expect(chef_run).to create_template('/root/.my.cnf').with(
        owner: 'root', group: 'root', mode: '0600')
    end

    it 'logrotate template has correct files' do
      rotate_path = '/etc/logrotate.d/mysql'
      expect(chef_run).to render_file(rotate_path).with_content(
        '"/var/log/mysqld.log" "/var/log/mysqld-slow.log" {')
    end

    it 'logrotate template has correct user/group' do
      expect(chef_run).to render_file('/etc/logrotate.d/mysql').with_content(
        'create 640 mysql mysql')
    end

    it 'logrotate template has correct auth' do
      rotate_path = '/etc/logrotate.d/mysql'
      expect(chef_run).to render_file(rotate_path).with_content(
        'AUTH="--defaults-file=/root/.my.cnf"')
    end

    context 'with no root password' do
      it 'does not set root password' do
        expect(chef_run).not_to set_mysqld_password('root')
      end

      it 'root .my.cnf has blank password' do
        expect(chef_run).to render_file('/root/.my.cnf')
          .with_content(/^password = $/)
      end
    end

    context 'with root password' do
      let(:password) { 'foo' }

      it 'sets password' do
        expect(chef_run).to set_mysqld_password('root').with(password: 'foo')
      end

      it 'root .my.cnf has correct password' do
        expect(chef_run).to render_file('/root/.my.cnf')
          .with_content('password = foo')
      end

      it 'logrotate template has correct auth' do
        rotate_path = '/etc/logrotate.d/mysql'
        expect(chef_run).to render_file(rotate_path).with_content(
          'AUTH="--defaults-file=/root/.my.cnf"')
      end
    end
  end

  context 'with ubuntu 14.04' do
    let(:platform) { 'ubuntu' }
    let(:platform_version) { '14.04' }

    %w(5.5 5.6).each do |v|
      context "with supported version #{v}" do
        let(:version) { v }
        it 'does not raise error' do
          expect { chef_run }.not_to raise_error
        end

        it 'install mysql-server package' do
          expect(chef_run).to install_package("mysql-server-#{v}")
        end
      end
    end

    it 'logrotate template has correct files' do
      rotate_path = '/etc/logrotate.d/mysql-server'
      expect(chef_run).to render_file(rotate_path).with_content(
        '"/var/log/mysql/error.log" "/var/log/mysql/slow-query.log" {')
    end

    it 'logrotate template has correct user/group' do
      rotate_path = '/etc/logrotate.d/mysql-server'
      expect(chef_run).to render_file(rotate_path).with_content(
        'create 640 mysql adm')
    end

    it 'logrotate template has correct auth' do
      rotate_path = '/etc/logrotate.d/mysql-server'
      expect(chef_run).to render_file(rotate_path).with_content(
        'AUTH="--defaults-file=/etc/mysql/debian.cnf"')
    end

    it 'does not create root .my.cnf' do
      expect(chef_run).not_to create_template('/root/.my.cnf')
    end

    context 'when debian-sys-maint password not specified' do
      it 'does not set debian-sys-maint password' do
        expect(chef_run).not_to set_mysqld_password('debian-sys-maint')
      end
    end

    context 'when debian-sys-maint password set' do
      let(:maint_passwd) { 'bar' }
      it 'sets debian-sys-maint password' do
        expect(chef_run).to set_mysqld_password('debian-sys-maint').with(password: 'bar')
      end
    end
  end

  it 'configures mysql' do
    expect(chef_run).to create_mysqld
  end
end
