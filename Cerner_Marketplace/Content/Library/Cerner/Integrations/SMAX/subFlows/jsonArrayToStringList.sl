namespace: Cerner.Integrations.SMAX.subFlows
operation:
  name: jsonArrayToStringList
  inputs:
    - entityArray: '{"complexTypeProperties":[{"properties":{"id":"600e0b90-4ad4-4416-af7c-18386746b017","file_name":"Cerner-Logo-square.png","file_extension":"png","size":5093,"mime_type":"image/png","Creator":"1000042","LastUpdateTime":1625861483000}},{"properties":{"id":"dc7ba199-3f33-444a-804d-2ade063cce59","file_name":"packaging-tool-error.log","file_extension":"log","size":29986,"mime_type":"application/octet-stream","Creator":"1000042","LastUpdateTime":1625861504000}},{"properties":{"id":"cf3244fa-a35a-49f3-a4a1-a5577035e77e","file_name":"itsma-vltid__itom-oo-336419949-5fb99d89d9-bbk8w.zip","file_extension":"zip","size":132512,"mime_type":"application/x-zip-compressed","Creator":"1000042","LastUpdateTime":1625861570000}}]}'
  python_action:
    use_jython: false
    script: "# do not remove the execute function \ndef execute(entityArray):\n    message = \"\"\n    result = \"\"\n    idFileNames  = \"\"\n    ids = \"\"\n    try:\n        import json\n        \n        \n        jr = json.loads(entityArray)\n        \n        message = jr\n        results = jr[\"complexTypeProperties\"]\n        message = results\n        listSize = 0\n        \n        \n        try:\n            for content in results:\n                if content.get('properties',{}).get('file_name'):\n                    idFileNames += content[\"properties\"][\"id\"]+\"||\"+content[\"properties\"][\"file_name\"]+ \"♪\"\n                    listSize += 1\n        \n            if len(idFileNames) > 0:\n                idFileNames = idFileNames[:-1]\n            \n        except Exception as e:\n            idFileNames  = \"\" \n        ids = idFileNames\n        \n        result = \"True\"\n    except Exception as e:\n        message = e\n        result = \"False\"\n    return {\"result\": result, \"message\": message, \"ids\": ids, \"listSize\": listSize }"
  outputs:
    - result
    - message
    - ids
    - listSize
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
