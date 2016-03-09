require 'bundler/setup'
require 'gooddata'
require 'active_support/all'
require_relative('stuff')

LOGIN = ''
PASSWORD = ''
TOKEN = ''
DOMAIN = ''
SERVER = ''

client = GoodData.connect(LOGIN, PASSWORD, server: SERVER, verify_ssl: false )
domain = client.domain(DOMAIN)

tempfile = Tempfile.new('association.csv')
headers = [:segment_id, :client_id]
CSV.open(tempfile.path, 'w') do |csv|
  csv << headers
  csv << ['basic_segment', 'acme']
  csv << ['basic_segment', 'hearst']
  csv << ['basic_segment', 'mastercard']
  csv << ['basic_segment', 'level_up']
end

service_segment = domain.segments('gd_service_segment')
service_project = service_segment.clients('gd_service_client').project
service_project.upload_file(tempfile.path, :filename => 'association.csv')
tempfile.delete

