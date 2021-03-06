require_relative 'spec_helper'

describe 'openstack-compute::_nova_cell' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(UBUNTU_OPTS) }
    let(:node) { runner.node }
    cached(:chef_run) { runner.converge(described_recipe) }

    include_context 'compute_stubs'
    include_examples 'expect_runs_nova_cell_recipe'

    it 'creates the cell0 mapping' do
      expect(chef_run).to run_execute('map cell0').with(
        user: 'nova',
        group: 'nova',
        command: 'nova-manage cell_v2 map_cell0 --database_connection mysql+pymysql://nova_cell0:nova_cell0_db_pass@127.0.0.1:3306/nova_cell0?charset=utf8'
      )
    end

    it 'creates a new cell' do
      expect(chef_run).to run_execute('create cell1').with(
        user: 'nova',
        group: 'nova',
        command: 'nova-manage cell_v2 create_cell --verbose --name cell1'
      )
    end

    it 'executes api_db sync' do
      expect(chef_run).to run_execute('api db sync').with(
        user: 'nova',
        group: 'nova',
        command: 'nova-manage api_db sync'
      )
    end

    it 'executes db sync' do
      expect(chef_run).to run_execute('db sync').with(user: 'nova', group: 'nova')
    end

    it 'discovers compute hosts' do
      expect(chef_run).to run_execute('discover hosts').with(user: 'nova', group: 'nova')
    end
  end
end
