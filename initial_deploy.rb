require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative('stuff')

LOGIN = ''
PASSWORD = ''
TOKEN = ''
DOMAIN = ''

client = GoodData.connect(LOGIN, PASSWORD, server: 'https://mustangs.intgdc.com', verify_ssl: false )
GoodData.logging_http_on
domain = client.domain(DOMAIN)
VERSION = '1.0.0'

#########
# BASIC #
#########

# blueprint = GoodData::Model::ProjectBlueprint.build("Basic Segment #{VERSION}") do |p|
#   p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
#     d.add_anchor('attr.departments.id', title: 'Department ID')
#     d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
#     d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
#     d.add_attribute('attr.departments.region', title: 'Department Region')
#     d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
#   end
# end
#
# basic_master_project = client.create_project_from_blueprint(blueprint, auth_token: TOKEN)
#
#
#
# load_process = redeploy_or_create_process(basic_master_project, './scripts/1.0.0/basic/load', name: 'load', type: :ruby)
# load_schedule = redeploy_or_create_schedule(load_process, '0 * * * *', 'main.rb', {
#   name: 'load'
# })
# load_schedule.disable!
#
# filters_process = redeploy_or_create_process(basic_master_project, 'appstore://user_filters_brick', name: 'users', type: :ruby)
# filters_schedule = redeploy_or_create_schedule(filters_process, load_schedule, 'main.rb', {
#   name: 'filters'
# })
# filters_schedule.disable!
#
#
# add_users_process = redeploy_or_create_process(basic_master_project, 'appstore://users_brick', name: 'users', type: :ruby)
# add_users_schedule = redeploy_or_create_schedule(add_users_process, filters_schedule, 'main.rb', {
#   name: 'users'
# })
# add_users_schedule.disable!
#
#
# service_segment = create_or_get_segment(domain, 'basic_segment', basic_master_project, version: VERSION)


###########
# PREMIUM #
###########
#
# blueprint = GoodData::Model::ProjectBlueprint.build("Basic Segment #{VERSION}") do |p|
#   p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
#     d.add_anchor('attr.departments.id', title: 'Department ID')
#     d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
#     d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
#     d.add_attribute('attr.departments.region', title: 'Department Region')
#     d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
#   end
# end
#
# premium_master_project = client.create_project_from_blueprint(blueprint, auth_token: TOKEN)
#
#
#
# filters_process = redeploy_or_create_process(premium_master_project, './scripts/1.0.0/premium/load', name: 'load', type: :ruby)
# filters_schedule = redeploy_or_create_schedule(filters_process, '0 * * * *', 'main.rb', {
#   name: 'load'
# })
# filters_schedule.disable!
#
# add_users_process = redeploy_or_create_process(premium_master_project, 'appstore://user_filters_brick', name: 'users', type: :ruby)
# add_users_schedule = redeploy_or_create_schedule(add_users_process, filters_schedule, 'main.rb', {
#   name: 'users'
# })
# add_users_schedule.disable!
#
#
# add_users_process = redeploy_or_create_process(premium_master_project, 'appstore://users_brick', name: 'users', type: :ruby)
# add_users_schedule = redeploy_or_create_schedule(add_users_process, add_users_schedule, 'main.rb', {
#   name: 'users'
# })
# add_users_schedule.disable!
#
#
# service_segment = create_or_get_segment(domain, 'premium_segment', basic_master_project, version: VERSION)


###########
# RELEASE #
###########

domain.synchronize_clients
domain.provision_client_projects

###########
# SERVICE #
###########

service_master_project = client.create_project(title: 'Service master', auth_token: TOKEN)

service_segment = create_or_get_segment(domain, 'gd_service_segment', service_master_project, version: VERSION)
service_client = create_or_get_client(service_segment, 'gd_service_client')

service_segment.synchronize_clients
domain.provision_client_projects

service_project = service_client.project

downloader_process = redeploy_or_create_process(service_project, './scripts/1.0.0/service/downloader', name: 'downloader', type: :ruby)
downloader_schedule = redeploy_or_create_schedule(downloader_process, '0 * * * *', 'main.rb', {
  name: 'downloader'
})
# downloader_schedule.disable!

association_process = redeploy_or_create_process(service_project, 'appstore://segments_workspace_association_brick', name: 'association', type: :ruby)
association_schedule = redeploy_or_create_schedule(association_process, downloader_schedule, 'main.rb', {
  name: 'association',
  params: {
    organization: DOMAIN,
    input_source: "association.csv",
    technical_client: { segment_id: 'gd_service_segment', client_id: 'gd_service_client' },
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: 'mustangs.intgdc.com'
  },
  hidden_params: {
    "GDC_USERNAME" => LOGIN,
    "GDC_PASSWORD" => PASSWORD
  }
})
# association_schedule.disable!

provisioning_process = redeploy_or_create_process(service_project, './scripts/apps/segment_provisioning_brick', name: 'provision', type: :ruby)
provisioning_schedule = redeploy_or_create_schedule(provisioning_process, association_schedule, 'main.rb', {
  name: 'provision',
  params: {
    organization: DOMAIN,
    CLIENT_GDC_PROTOCOL: 'https',
    CLIENT_GDC_HOSTNAME: 'mustangs.intgdc.com'
  },
  hidden_params: {
    "GDC_USERNAME" => LOGIN,
    "GDC_PASSWORD" => PASSWORD
  }
})
# provisioning_schedule.disable!


# DONE
puts HighLine.color('DONE', :green)
