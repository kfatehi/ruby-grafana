
module Grafana

  module Annotations

    # add standard annotations to all Templates
    #
    #
    def add_annotations( template_json )

      # add or overwrite annotations
      annotations = '
        {
          "list": [
            {
              "name": "created",
              "enable": false,
              "iconColor": "rgb(93, 227, 12)",
              "datasource": "events",
              "tags": "%STORAGE_IDENTIFIER% created&set=intersection"
            },
            {
              "name": "destroyed",
              "enable": false,
              "iconColor": "rgb(227, 57, 12)",
              "datasource": "events",
              "tags": "%STORAGE_IDENTIFIER% destroyed&set=intersection"
            },
            {
              "name": "Load Tests",
              "enable": false,
              "iconColor": "rgb(26, 196, 220)",
              "datasource": "events",
              "tags": "%STORAGE_IDENTIFIER% loadtest&set=intersection"
            },
            {
              "name": "Deployments",
              "enable": false,
              "iconColor": "rgb(176, 40, 253)",
              "datasource": "events",
              "tags": "%STORAGE_IDENTIFIER% deployment&set=intersection"
            }
          ]
        }
      '

      template_json = JSON.parse( template_json ) if( template_json.is_a?( String ) )
      annotation = template_json.dig( 'dashboard', 'annotations' )
      template_json['dashboard']['annotations'] = JSON.parse( annotations ) unless( annotation.nil? )

      template_json
    end

  end

end
