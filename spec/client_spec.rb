require_relative 'spec_helper'

describe 'mysql_community::client' do
  let(:platform) { nil }
  let(:platform_version) { nil }
  let(:version) { nil }
  let(:chef_run) do
    ChefSpec::SoloRunner.new(platform: platform,
                             version: platform_version) do |node|
      node.set['mysqld']['version'] = version
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
      expect(chef_run).to install_package('mysql-community-client')
    end

    it 'installs mysql-community-devel package' do
      expect(chef_run).to install_package('mysql-community-devel')
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

        it 'install mysql-client package' do
          expect(chef_run).to install_package("mysql-client-#{v}")
        end

        it 'installs foo package' do
          expect(chef_run).to install_package('libmysqlclient-dev')
        end
      end
    end
  end
end
