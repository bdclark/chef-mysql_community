require_relative 'spec_helper'

describe 'mysql_community::server' do
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
        it 'does not raise error' do
          expect { chef_run }.not_to raise_error
        end

        it "add mysql-community #{v} repo" do
          yum_recipe = "yum-mysql-community::mysql#{v.gsub('.', '')}"
          expect(chef_run).to include_recipe yum_recipe
        end
      end
    end

    context 'with unsupported version' do
      let(:version) { '5.1' }
      it 'raises an error' do
        expect { chef_run }.to raise_error
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

    it 'configures mysql' do
      expect(chef_run).to create_mysqld
    end
  end

  context 'with ubuntu platform' do
    let(:platform) { 'ubuntu' }
    context 'with 12.04' do
      let(:platform_version) { '12.04' }
    end
    context 'with 14.04' do
      let(:platform_version) { '14.04' }
    end
  end
end
