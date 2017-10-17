
module Grafana

  module DashboardTemplate

    def build_template( params = {} )

      params['from'] = 'now-2h' unless params.key?('from')
      params['to'] = 'now' unless params.key?('to')

      return false if params['title'] == ''

      rows = []
      params['panels'].each do |panel|
        rows.push(build_panel(panel))
      end

      tpl = '
      {
        "dashboard": {
          "id": null,
          "title": "%{title}",
          "originalTitle": "%{title}",
          "annotations": {
            "list": []
          },
          "hideControls": false,
          "timezone": "browser",
          "editable": true,
          "rows": [
            %{rows}
          ],
          "time": {
            "from": "%{from}",
            "to": "%{to}"
          },
          "timepicker": {
            "collapse": false,
            "enable": true,
            "notice": false,
            "now": true,
            "refresh_intervals": [
              "5s",
              "10s",
              "30s",
              "1m",
              "5m",
              "15m",
              "30m",
              "1h",
              "2h",
              "1d"
            ],
            "status": "Stable",
            "time_options": [
              "5m",
              "15m",
              "1h",
              "6h",
              "12h",
              "24h",
              "2d",
              "7d",
              "30d"
            ],
            "type": "timepicker"
          },
          "tags": ["api-templated"],
          "templating": {
            "list": []
          },
          "schemaVersion": 7,
          "sharedCrosshair": false,
          "style": "dark",
          "version": 1,
          "links": []
        },
        "overwrite": false
      }
      '

      format(
        tpl,
        title: params['title'],
        from: params['from'],
        to: params['to'],
        rows: rows.join(',')
      )

    end


    def build_panel( params = {} )

      panel = '
        {
          "collapse": false,
          "editable": true,
          "height": "250px",
          "panels": [
            {
              "aliasColors": {},
              "bars": false,
              "datasource": "%{datasource}",
              "editable": true,
              "error": false,
              "fill": 1,
              "grid": {
                "leftLogBase": 1,
                "leftMax": null,
                "leftMin": null,
                "rightLogBase": 1,
                "rightMax": null,
                "rightMin": null,
                "threshold1": null,
                "threshold1Color": "rgba(216, 200, 27, 0.27)",
                "threshold2": null,
                "threshold2Color": "rgba(234, 112, 112, 0.22)"
              },
              "legend": {
                "avg": false,
                "current": false,
                "max": false,
                "min": false,
                "show": true,
                "total": false,
                "values": false
              },
              "lines": true,
              "linewidth": 2,
              "links": [],
              "nullPointMode": "connected",
              "percentage": false,
              "pointradius": 5,
              "points": false,
              "renderer": "flot",
              "seriesOverrides": [],
              "span": 12,
              "stack": false,
              "steppedLine": false,
              "targets": [
                %{targets}
              ],
              "timeFrom": null,
              "timeShift": null,
              "title": "%{graph_title}",
              "tooltip": {
                "shared": true,
                "value_type": "cumulative"
              },
              "type": "graph",
              "x-axis": true,
              "y-axis": true,
              "y_formats": [
                "short",
                "short"
              ]
            }
          ],
          "title": "Row"
        }
      '

      targets = []
      params['targets'].each do |t|
        targets.push(build_target(t))
      end

      format(
        panel,
        datasource: params['datasource'],
        graph_title: params['graph_title'],
        targets: targets.join(',')
      )

    end


    def build_target( params = {} )

      target = '
        {
          "alias": "%{legend_alias}",
          "dimensions": {
            "%{dimension_name}": "%{dimension_value}"
          },
          "metricName": "%{metric_name}",
          "namespace": "%{namespace}",
          "period": 60,
          "query": "",
          "refId": "A",
          "region": "%{region}",
          "statistics": [
            "Maximum"
          ],
          "timeField": "@timestamp"
        }
      '

      format(
        target,
        metric_name: params['metric_name'],
        namespace: params['namespace'],
        dimension_name: params['dimension_name'],
        dimension_value: params['dimension_value'],
        region: params['region'],
        legend_alias: params['legend_alias']
      )

    end

  end

end

