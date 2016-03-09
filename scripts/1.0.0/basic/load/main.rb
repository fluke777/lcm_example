# encoding: utf-8
puts "1"
# require 'gooddata'
#
# include GoodData::Bricks
#
# p = GoodData::Bricks::Pipeline.prepare([
#   DecodeParamsMiddleware,
#   LoggerMiddleware,
#   BenchMiddleware,
#   GoodDataMiddleware,
#   Proc.new do |params|
#     client = params['GDC_GD_CLIENT'] || fail('client needs to be passed into a brick as "GDC_GD_CLIENT"')
#     project = client.projects(params['gdc_project'])
#     blueprint = GoodData::Model::ProjectBlueprint.build('HR Demo Project') do |p|
#       p.add_dataset('dataset.departments', title: 'Department', folder: 'Department & Employee') do |d|
#         d.add_anchor('attr.departments.id', title: 'Department ID')
#         d.add_label('label.departments.id', reference:'attr.departments.id', title: 'Department ID')
#         d.add_label('label.departments.name', reference: 'attr.departments.id', title: 'Department Name')
#         d.add_attribute('attr.departments.region', title: 'Department Region')
#         d.add_label('label.departments.region', reference: 'attr.departments.region', title: 'Department Region')
#       end
#     end
#     data = [
#       ["label.departments.id", "label.departments.name", "label.departments.region"],
#       [1, 'HR', 'US'],
#       [2, 'Sales', 'US'],
#       [3, 'Engineering', 'CZ']]
#     project.upload(devs_data, blueprint, 'dataset.departments')
#   end
# ])
