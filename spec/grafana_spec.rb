# frozen_string_literal: true

# require 'spec_helper'
require 'rspec'
require 'grafana'

RSpec.configure do |config|
  config.mock_with :rspec
end

describe Grafana do

  before do

    config = {
      debug: false,
      grafana: {
        host: 'localhost',
        port: 3030
      }
    }

    @g  = Grafana::Client.new( config )
    @g.login(username: 'admin', password: 'admin')
  end

  describe 'Instance' do

    it 'login' do
      expect(@g.login(username: 'admin', password: 'admin')).to be_truthy
    end
  end


  describe 'Admin' do

    it 'ping session' do
      r = @g.ping_session

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message  = r.dig('message')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(message).to be_a(String)
      expect(message).to be == 'Logged in'
    end

    it 'admin settings' do
      r = @g.admin_settings

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'admin stats' do
      r = @g.admin_stats

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'add user \'spec-test-1\'' do

      r = @g.add_user(
        user_name:'spec-test-1',
        email: 'spec-test-1@bar.com',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      id = r.dig('id')
      status = r.dig('status')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'add user \'spec-test-2\'' do

      r = @g.add_user(
        user_name:'spec-test-2',
        email: 'spec-test-2@bar.com',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      id = r.dig('id')
      status = r.dig('status')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'add user \'spec-test-1\' (again)' do

      r = @g.add_user(
        user_name:'spec-test-1',
        email: 'spec-test-1@bar.com',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      id = r.dig('id')
      status = r.dig('status')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
      expect(status).to be == 404
    end

    it 'delete admin user' do
      r = @g.delete_user(0)
      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 403
    end

    it 'set Password for User \'spec-test-1\'' do

      r = @g.update_user_password( user_name: 'spec-test-1', password: 'foor' )
      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'update user permissions (\'spec-test-1\')' do

      params = {
        user_name: 'spec-test-1@bar.com',
        permissions: 'Viewer'
      }
      r = @g.update_user_permissions( params )

      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'update user permissions (\'spec-test-2\')' do

      params = {
        user_name: 'spec-test-2',
        permissions: { grafana_admin: true }
      }
      r = @g.update_user_permissions( params )

      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'delete user with id (\'spec-test-1\')' do

      usr = @g.user('spec-test-1@bar.com')
      id = usr['id']

      r = @g.delete_user(id)
      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'delete user with username (\'spec-test-2\')' do
      r = @g.delete_user('spec-test-2@bar.com')
      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'pause all alerts' do
      r = @g.pause_all_alerts

      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

  end


  describe 'create demo data' do

    it 'Create \'graphite\' data source' do
      r = @g.create_datasource(
        name: 'graphite',
        type: 'graphite',
        database: 'graphite',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'import dashboards from directory' do
      r = @g.import_dashboards_from_directory('spec/dashboards')
      expect(r).to be_a(Hash)
      expect(r.count).to be == 2
      expect(r.select { |k, v| v['status'] == 200 }.count).to be 2
    end

  end

  # Alerts are currently not functional (FOR ME!)
  # needs some Q&A with the grafana team
  #
#  describe 'Alerts' do
#
#    it 'create alert notification' do
#      params = {
#        name: 'new alert notification',
#        type:  'email',
#        default: true,
#        settings: {
#          addresses: 'foo@bar.com;spec-test@test.com'
#        }
#      }
#      r = @g.create_alert_notification( params )
#      expect(r).to be_a(Hash)
#      status  = r.dig('status')
#      id      = r.dig('id')
#      expect(status).to be == 200
#
##       puts "create: #{r}"
#    end
#
#    it 'get all alerts notification' do
#      params = {}
#      r = @g.alert_notifications
#      expect(r).to be_a(Hash)
#      status  = r.dig('status')
#      message = r.dig('message')
#      expect(status).to be == 200
#      expect(message).to be_a(Array)
#
##       puts "get: #{r}"
#    end
#
#    it 'update alert notification' do
#      params = {
#        alert_id: 'new alert notification',
#        name: 'renamed alert notification',
#        type:  'email',
#        default: true,
#        settings: {
#          addresses: 'foo@bar.com;spec-test@test.com'
#        }
#      }
#      r = @g.update_alert_notification( params )
#      puts "update: #{r}"
#      expect(r).to be_a(Hash)
#      status  = r.dig('status')
#      expect(status).to be == 200
#    end
##
##    it 'get paused and pending alerts' do
##
##      params = {
##        alerts: ['paused', 'pending']
##      }
##      r = @g.alerts(params)
##      expect(r).to be_a(Hash)
##      status  = r.dig('status')
##      message = r.dig('message')
##      expect(status).to be == 200
##      expect(message).to be_a(Array)
##    end
#
#
#
#    it 'delete alert notification' do
#      r = @g.delete_alert_notification( 'new alert notification' )
#      puts "delete: #{r}"
#
#      expect(r).to be_a(Hash)
#      status  = r.dig('status')
#      expect(status).to be == 200
#    end
#
#  end


  describe 'Datasources' do

    it 'Create \'graphite-2\' data source' do
      r = @g.create_datasource(
        name: 'graphite-2',
        type: 'graphite',
        database: 'graphite',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'cloudwatch\' data source' do
      r = @g.create_datasource(
        name: 'cloudwatch',
        type: 'cloudwatch',
        database: 'cloudwatch',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'elasticsearch\' data source' do
      r = @g.create_datasource(
        name: 'elasticsearch',
        type: 'elasticsearch',
        database: 'elasticsearch',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'prometheus\' data source' do
      r = @g.create_datasource(
        name: 'prometheus',
        type: 'prometheus',
        database: 'prometheus',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'influxdb\' data source' do
      r = @g.create_datasource(
        name: 'influxdb',
        type: 'influxdb',
        database: 'influxdb',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'mysql\' data source' do
      r = @g.create_datasource(
        name: 'mysql',
        type: 'mysql',
        database: 'mysql',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'opentsdb\' data source' do
      r = @g.create_datasource(
        name: 'opentsdb',
        type: 'opentsdb',
        database: 'opentsdb',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'postgres\' data source' do
      r = @g.create_datasource(
        name: 'postgres',
        type: 'postgres',
        database: 'postgres',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create \'grafana\' data source' do
      r = @g.create_datasource(
        name: 'grafana',
        type: 'grafana',
        database: 'grafana',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Update an existing data source \'graphite-2\'' do
      r = @g.update_datasource(
        name: 'graphite-2',
        organisation: 1,
        url: 'http://localhost:2003'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get all datasources' do
      r = @g.datasources
      expect(r).to be_a(Hash)
      expect(r.keys.count).to be >= 9
    end

    it 'Get a single data sources by Name' do
      r = @g.datasource('graphite')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get a single data sources by Id' do
      r = @g.datasources
      id = r.keys.first
      r = @g.datasource(id)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Create data source \'foo-2\'' do
      r = @g.create_datasource(
        name: 'foo-2',
        type: 'graphite',
        database: 'foo-2',
        access: 'proxy',
        url: 'http://localhost:8080'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Update an existing data source \'foo-2\'' do
      r = @g.update_datasource(
        name: 'foo-2',
        type: 'influxdb',
        url: 'http://localhost:2003'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Delete an existing data source \'foo-2\' (by name)' do
      r = @g.delete_datasource('foo-2')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'delete all created datasources' do

      %w[grafana graphite-2 cloudwatch elasticsearch prometheus influxdb mysql opentsdb postgres].each do |d|
        r = @g.delete_datasource(d)
        expect(r).to be_a(Hash)
      end
    end

  end


  describe 'Organisation' do

    it 'Get current Organisation' do
      r = @g.current_organization
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get all Organisations' do
      r = @g.organizations
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get Organisation by Id' do
      r = @g.organization(1)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get Organisation by Name' do
      r = @g.organization('Docker')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get all users within the actual organisation' do
      r = @g.current_organization_users
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Update current Organisation' do
      r = @g.update_current_organization( name: 'foo')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end


    it 'Restore current Organisation' do
      r = @g.update_current_organization( name: 'Docker')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end


    it 'Add a new user to the actual organisation' do
      r = @g.add_user_to_current_organization(
        role: 'Viewer',
        login_or_email: 'spec-test@bar.com'
      )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
    end

  end


  describe 'Organisations' do

    it 'Create Organisation' do
      r = @g.create_organisation( name: 'Spec Test' )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      org_id  = r.dig('orgId')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(org_id).to be_a(Integer)
    end

    it 'Search all Organisations' do
      r = @g.organizations

      expect(r).to be_a(Hash)

      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Get Organisation by Id' do

      r = @g.organization( 1 )

      expect(r).to be_a(Hash)

      status  = r.dig('status')
      id      = r.dig('id')
      name    = r.dig('name')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(id).to be_a(Integer)
      expect(name).to be_a(String)
    end

    it 'Get Organisation by Name' do
      r = @g.organization( 'Spec Test' )

      expect(r).to be_a(Hash)

      status  = r.dig('status')
      id      = r.dig('id')
      name    = r.dig('name')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(id).to be_a(Integer)
      expect(name).to be_a(String)
      expect(name).to be == 'Spec Test'

    end

    it 'Update Organisation' do

      org = @g.organization('Spec Test')
      id   = org.dig('id')
      name = org.dig('name')

      r = @g.update_organization( organization: 'Spec Test', name: 'Spec+Test' )
      expect(r).to be_a(Hash)

      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200

      r = @g.update_organization( organization: 'Spec+Test', name: 'Spec Test' )
    end

    it 'Get Users in Organisation with Organisation Name' do
      r = @g.organization_users('Spec Test')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.size).to be >= 1
    end

    it 'Get Users in Organisation with Organisation Id' do

      org = @g.organization('Spec Test')
      id   = org.dig('id')
      name = org.dig('name')

      r = @g.organization_users(id)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.size).to be >= 1
    end

    it 'Add temporary User for Organisation' do
      r = @g.add_user(
        user_name:'foo',
        email: 'foo@foo-bar.tld',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      status = r.dig('status')
      id = r.dig('id')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
    end

    it 'Add User in Organisation - successful' do
      params = {
        organization: 'Spec Test',
        login_or_email: 'foo@foo-bar.tld',
        role: 'Editor'
      }
      r = @g.add_user_to_organization( params )
      expect(r).to be_a(Hash)
      status  = r.dig('status')

      if(status != 200)
        puts r
      end

      expect(status).to be == 200
    end

    it 'Add User in Organisation - failed' do
      params = {
        organization: 'Spec Test',
        login_or_email: 'foo-2@foo-bar.tld',
        role: 'Foo'
      }
      r = @g.add_user_to_organization( params )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 404
    end

    it 'Update Users in Organisation - successful' do
      params = {
        organization: 'Spec Test',
        login_or_email: 'foo@foo-bar.tld',
        role: 'Viewer'
      }
      r = @g.update_organization_user( params )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
    end

    it 'Update Users in Organisation - failed' do
      params = {
        organization: 'Spec Test',
        login_or_email: 'foo-2@foo-bar.tld',
        role: 'Bar'
      }
      r = @g.update_organization_user( params )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 404
    end

    it 'Delete User in Organisation' do
      r = @g.delete_user_from_organization( organization: 'Spec Test', login_or_email: 'foo@foo-bar.tld' )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
    end

    it 'Delete Organisation' do
      r = @g.delete_organisation( 'Spec Test' )
      expect(r).to be_a(Hash)
      status = r.dig('status')
      message = r.dig('message')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(message).to be_a(String)
    end

    it 'delete temporary User for Organisation' do
      r = @g.delete_user('foo@foo-bar.tld')
      expect(r).to be_a(Hash)
      status = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

  end


  describe 'User' do

    it 'Actual User' do
      r = @g.current_user
      expect(r).to be_a(Hash)
      status  = r.dig('status')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Organisations of the actual User' do
      r = @g.current_user_oganizations
      expect(r).to be_a(Hash)
      status  = r.dig('status')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'import dashboards from directory' do
      r = @g.import_dashboards_from_directory('spec/dashboards')
      expect(r).to be_a(Hash)
    end

    it 'Star a dashboard' do
      r = @g.add_dashboard_star( 'QA Graphite Carbon Metrics' )
      expect(r).to be_a(Hash)
      status  = r.dig('status')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Unstar a dashboard' do
      r = @g.remove_dashboard_star( 'QA Graphite Carbon Metrics' )
      expect(r).to be_a(Hash)
      status  = r.dig('status')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end


    it 'delete dashboard' do
      search = { :tags => 'QA' }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).equal?(2)

      message.each do |m|
        title = m.dig('title')
        r = @g.delete_dashboard(title)
        expect(r).to be_a(Hash)
        status  = r.dig('status')
        expect(status).to be == 200
      end

    end
  end


  describe 'Users' do

    it 'get all Users' do
      r = @g.users
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(message).to be_a(Array)
      expect(message.count).to be >= 1
    end

    it 'add temporary User' do
      r = @g.add_user(
        user_name:'foo',
        email: 'foo@foo-bar.tld',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      status = r.dig('status')
      id = r.dig('id')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
    end

    it 'get users by Id (1) - must be successful' do
      r = @g.user(1)

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'get users by Id (2) - must be failed' do
      r = @g.user(2)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')

      expect(status).to be_a(Integer)
      expect(status).to be == 404
    end

    it 'get users by Name - must be successful' do
      r = @g.user( 'admin@localhost' )
      expect(r).to be_a(Hash)

      status  = r.dig('status')
      message = r.dig('message')

      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'add another temporary User' do
      r = @g.add_user(
        user_name:'foo-2',
        email: 'foo-2@foo-bar.tld',
        password: 'pass'
      )
      expect(r).to be_a(Hash)

      status = r.dig('status')
      id = r.dig('id')
      message = r.dig('message')
      expect(r).to be_a(Hash)
      expect(status).to be_a(Integer)
      expect(id).to be_a(Integer)
    end

    it 'search for Users by (admin == true)' do
      r = @g.search_for_users_by( isAdmin: true )
      expect(r).to be_a(Array)
    end

    it 'Search for Users by (login == foo)' do
      r = @g.search_for_users_by( login: 'foo' )
      expect(r).to be_a(Array)
    end

    it 'Get Organisations for user' do

      r = @g.user_organizations('foo@foo-bar.tld')

      expect(r).to be_a(Hash)

      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'Update Users' do

      r = @g.update_user(
        user_name: 'foo-2',
        theme: 'light',
        login_name: 'spec-test',
        email: 'spec-test@foo-bar.tld'
      )
      expect(r).to be_a(Hash)

      status  = r.dig('status')
      message = r.dig('message')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
      expect(message).to be_a(String)
      #expect(message).to be == 200

#       r = @g.update_user(
#         user_name: 'spec-test',
#         email: 'foo@foo-bar.tld',
#       )
#       expect(r).to be_a(Hash)

    end

#     it 'delete temporary User' do
#       r = @g.delete_user('foo@foo-bar.tld')
#       expect(r).to be_a(Hash)
#       status = r.dig('status')
#       expect(status).to be_a(Integer)
#       expect(status).to be == 200
#     end


  end


  describe 'Dashboards' do

    it 'import dashboards from directory' do
      r = @g.import_dashboards_from_directory('spec/dashboards')
      expect(r).to be_a(Hash)
      expect(r.count).to be == 2
      expect(r.select { |k, v| v['status'] == 200 }.count).to be 2
    end

    it 'dashboards tags' do
      r = @g.dashboard_tags
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
    end

    it 'home dashboard' do
      r = @g.home_dashboard
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
    end

    it 'search tagged dashboards' do
      search = { tags: 'QA' }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).equal?(2)
    end

    it 'search starred dashboards' do
      search = { starred: true }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).to be == 0
    end

    it 'search dashboards with query' do
      search = { query: 'QA Graphite Carbon Metrics' }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).to be == 1
    end

    it 'list dashboard' do
      search = { query: 'QA Graphite Carbon Metrics' }
      r = @g.search_dashboards( search )
      message = r.dig('message')
      title = message.first.dig('title')
      r = @g.dashboard(title)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be == 200
      t = r.dig('dashboard','title')
      expect(t).to be_a(String)
      expect(t).equal?(title)
    end

    it 'delete dashboard' do
      search = { tags: 'QA' }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).equal?(2)

      message.each do |m|
        title = m.dig('title')
        r = @g.delete_dashboard(title)
        expect(r).to be_a(Hash)
        status  = r.dig('status')
        expect(status).to be == 200
      end

    end

  end


  describe 'Annotations' do

    it 'import dashboards from directory' do
      r = @g.import_dashboards_from_directory('spec/dashboards')
      expect(r).to be_a(Hash)
      expect(r.count).to be == 2
      expect(r.select { |k, v| v['status'] == 200 }.count).to be 2
    end


    it 'create annotation' do
      params = {
        time: Time.now.to_i,
        region: false,
        tags: [ 'spec', 'test' ],
        text: 'test annotation'
      }
      r = @g.create_annotation(params)

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')
      expect(status).to be == 200
      expect(message).to be_a(String)
    end


    it 'create graphite annotation' do

      params = {
        what: 'spec test graphite annotation',
        when: Time.now.to_i,
        tags: [ 'spec', 'test' ],
        text: 'test annotation'
      }
      r = @g.create_annotation_graphite(params)

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')
      expect(status).to be == 200
      expect(message).to be_a(String)
    end


    it 'update annotation' do

      params = {
        limit: 5,
        tags: [ 'spec', 'test' ]
      }
      r = @g.find_annotation(params)

      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')
      if( status.to_i == 200 )
        message = message.first
        annotation_id = message.dig('id')
      end

      params = {
        annotation: annotation_id,
        region: false,
        tags: [ 'spec', 'test', 'correcting' ],
        text: 'new text ... (test annotation)'
      }
      r = @g.update_annotation(params)
    end


    it 'find annotation' do
      params = {
        limit: 10
      }
      r = @g.find_annotation(params)
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      message = r.dig('message')
      expect(status).to be == 200
      expect(message).to be_a(Array)
    end


    it 'delete annotation' do
      r = @g.delete_annotation(1)
      expect(r).to be_a(Hash)
#       status  = r.dig('status')
#       expect(status).to be == 200
    end

    it 'delete annotation by region' do
      r = @g.delete_annotation_by_region(1)
      expect(r).to be_a(Hash)
#       status  = r.dig('status')
#       expect(status).to be == 200
    end

  end



  describe 'remove demo data' do

    it 'Delete an existing data source \'graphite\' (by name)' do
      r = @g.delete_datasource('graphite')
      expect(r).to be_a(Hash)
      status  = r.dig('status')
      expect(status).to be_a(Integer)
      expect(status).to be == 200
    end

    it 'delete dashboard' do
      search = { tags: 'QA' }
      r = @g.search_dashboards( search )
      expect(r).to be_a(Hash)
      message = r.dig('message')
      expect(message).to be_a(Array)
      expect(message.count).equal?(2)

      message.each do |m|
        title = m.dig('title')
        r = @g.delete_dashboard(title)
        expect(r).to be_a(Hash)
        status  = r.dig('status')
        expect(status).to be == 200
      end

    end

  end
end

