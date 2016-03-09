require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative('../stuff')

LOGIN = ''
PASSWORD = ''
TOKEN = ''
DOMAIN = ''
SERVER = ''

client = GoodData.connect(LOGIN, PASSWORD, server: SERVER, verify_ssl: false )
domain = client.domain(DOMAIN)

release(domain, '2.0.0', auth_token: TOKEN) do |release|
  release.with_segment('basic_segment') do |segment, new_master_project|
    blueprint = new_master_project.blueprint
    blueprint.datasets('dataset.departments').change do |d|
      d.add_fact('fact.departments.number', title: 'NUMBER')
    end
    new_master_project.update_from_blueprint(blueprint)
    redeploy_or_create_process(new_master_project, './scripts/load/2.0.0', name: 'load')
  end
end
