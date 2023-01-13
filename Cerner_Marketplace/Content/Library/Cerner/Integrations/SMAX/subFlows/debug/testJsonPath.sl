namespace: Cerner.Integrations.SMAX.subFlows.debug
flow:
  name: testJsonPath
  inputs:
    - inputJSON: "${{\n\t\t\"entity_type\": \"Request\",\n\t\t\"properties\": {\n\t\t\t\"RequestAttachments\": {\n\t\t\t\t\"complexTypeProperties\": [\n\t\t\t\t\t{\n\t\t\t\t\t\t\"properties\": {\n\t\t\t\t\t\t\t\"id\": \"600e0b90-4ad4-4416-af7c-18386746b017\",\n\t\t\t\t\t\t\t\"file_name\": \"Cerner-Logo-square.png\",\n\t\t\t\t\t\t\t\"file_extension\": \"png\",\n\t\t\t\t\t\t\t\"size\": 5093,\n\t\t\t\t\t\t\t\"mime_type\": \"image/png\",\n\t\t\t\t\t\t\t\"Creator\": \"1000042\",\n\t\t\t\t\t\t\t\"LastUpdateTime\": 1625861483000\n\t\t\t\t\t\t}\n\t\t\t\t\t},\n\t\t\t\t\t{\n\t\t\t\t\t\t\"properties\": {\n\t\t\t\t\t\t\t\"id\": \"dc7ba199-3f33-444a-804d-2ade063cce59\",\n\t\t\t\t\t\t\t\"file_name\": \"packaging-tool-error.log\",\n\t\t\t\t\t\t\t\"file_extension\": \"log\",\n\t\t\t\t\t\t\t\"size\": 29986,\n\t\t\t\t\t\t\t\"mime_type\": \"application/octet-stream\",\n\t\t\t\t\t\t\t\"Creator\": \"1000042\",\n\t\t\t\t\t\t\t\"LastUpdateTime\": 1625861504000\n\t\t\t\t\t\t}\n\t\t\t\t\t},\n\t\t\t\t\t{\n\t\t\t\t\t\t\"properties\": {\n\t\t\t\t\t\t\t\"id\": \"cf3244fa-a35a-49f3-a4a1-a5577035e77e\",\n\t\t\t\t\t\t\t\"file_name\": \"itsma-vltid__itom-oo-336419949-5fb99d89d9-bbk8w.zip\",\n\t\t\t\t\t\t\t\"file_extension\": \"zip\",\n\t\t\t\t\t\t\t\"size\": 132512,\n\t\t\t\t\t\t\t\"mime_type\": \"application/x-zip-compressed\",\n\t\t\t\t\t\t\t\"Creator\": \"1000042\",\n\t\t\t\t\t\t\t\"LastUpdateTime\": 1625861570000\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t]\n\t\t\t},\n\t\t\t\"LastUpdateTime\": 1625865458026,\n\t\t\t\"Id\": \"17448\",\n\t\t\t\"DisplayLabel\": \"Artifactory - Incident - Under Construction\"\n\t\t},\n\t\t\"related_properties\": {}\n\t}}"
  workflow:
    - jsonArrayToStringList:
        do:
          Cerner.Integrations.SMAX.subFlows.jsonArrayToStringList: []
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      jsonArrayToStringList:
        x: 108
        'y': 125.421875
        navigate:
          e6782932-a809-0bfb-f600-f3ab15054e5f:
            targetId: 09129b2a-3baa-97f2-e552-f6364dac054e
            port: SUCCESS
    results:
      SUCCESS:
        09129b2a-3baa-97f2-e552-f6364dac054e:
          x: 402
          'y': 249
