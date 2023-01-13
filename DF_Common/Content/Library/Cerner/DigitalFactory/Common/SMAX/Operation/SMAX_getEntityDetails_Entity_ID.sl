########################################################################################################################
#!!
#! @input entity: SMAX App Entity Table name
#! @input query_field: coma separated key value pair like "RequestId,12345" on which to search the data
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: SMAX_getEntityDetails_Entity_ID
  inputs:
    - smax_url: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
    - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
    - smax_auth_token
    - entity
    - query_field
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get entity ids for specicific conditions records\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Operation: SMAX_getEntityDetails_Etity_ID\r\n#   Inputs:\r\n#       -   smax_url\r\n#       -   smax_tenantId\r\n#       -   smax_auth_token\r\n#       -   entity\r\n#       -   query_field\r\n#       -   entity_fields\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   entity_ids\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n#       -   errorProvder\r\n#       -   errorType\r\n#       -\r\n###############################################################\r\nimport json\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\ndef execute(smax_url, smax_auth_token, smax_tenantId, entity, query_field):\r\n    message = \"\"\r\n    result = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    entity_ids = \"\"\r\n    records = 0\r\n\r\n    try:\r\n        import json\r\n        import requests\r\n        queryKey = query_field.split(',')[0]\r\n        queryValue = query_field.split(',')[1]\r\n\r\n        url = smax_url + \"/rest/\" + smax_tenantId + \"/ems/\" + entity\r\n        url += \"?filter=\" + queryKey + \"='\" + queryValue + \"'&layout=Id\"\r\n\r\n        headers = {\r\n            'Cookie': 'LWSSO_COOKIE_KEY=' + smax_auth_token,\r\n            'Content-Type': 'application/json',\r\n            'User-Agent': 'Apache-HttpClient/4.4.1'\r\n        }\r\n\r\n        response = requests.request(\"GET\", url, headers=headers)\r\n        message = response.text\r\n        mresponse = json.loads(response.text)\r\n\r\n        if response.status_code == 200:\r\n            if mresponse[\"meta\"][\"completion_status\"] == \"FAILED\":\r\n                msg = str(message)\r\n                raise Exception(msg)\r\n            if mresponse[\"meta\"][\"total_count\"] >0:\r\n                i = 0\r\n                for rec in mresponse[\"entities\"]:\r\n                    entity_ids += rec[\"properties\"][\"Id\"] + \",\"\r\n                    i += 1\r\n                entity_ids = entity_ids[:-1]\r\n                records = i\r\n                message = \"Entity Details retrieved from SMAX \" + entity\r\n            else:\r\n                message = \"No Records found for given criteria from \" + entity\r\n            result = \"True\"\r\n        else:\r\n            msg = 'Cannot Open Connection to SMAX, Wrong URL or Wrong User password or SMAX not Available'\r\n            raise Exception(msg)\r\n    except Exception as e:\r\n        message = e\r\n        errorMessage = message\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'SMAX'\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"message\": message, \"records\": records,\"entity_ids\": entity_ids,\"errorType\": errortype, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider }"
  outputs:
    - result
    - message
    - records
    - entity_ids
    - errorMessage
    - errorSeverity
    - errorProvder
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
