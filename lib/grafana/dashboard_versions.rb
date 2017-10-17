
module Grafana

  # http://docs.grafana.org/http_api/dashboard_versions/
  #
  module DashboardVersions

    # Get all dashboard versions
    #
    # Query parameters:
    #
    # limit - Maximum number of results to return
    # start - Version to start from when returning queries
    # GET /api/dashboards/id/:dashboardId/versions
    def dashboard_all_versions( params )
      raise ArgumentError.new('params must be an Hash') unless( params.is_a?(Hash) )
      puts 'TODO'
    end

    # Get dashboard version
    # GET /api/dashboards/id/:dashboardId/versions/:id
    def dashboard_versions( params )
      raise ArgumentError.new('params must be an Hash') unless( params.is_a?(Hash) )
      puts 'TODO'
    end

    # Restore dashboard
    # POST /api/dashboards/id/:dashboardId/restore
    def restore_dashboard( params )
      raise ArgumentError.new('params must be an Hash') unless( params.is_a?(Hash) )
      puts 'TODO'
    end


    # Compare dashboard versions
    # POST /api/dashboards/calculate-diff
    def compare_dashboard_versions( params )
      raise ArgumentError.new('params must be an Hash') unless( params.is_a?(Hash) )
      puts 'TODO'
    end

  end

end
