########################################################################################################################
#!!
#! @input entity: SMAX App Entity Table name
#! @input query_field: coma separated key value pair like "RequestId,12345" on which to search the data
#! @input entity_fields: entity fields (comma separated list)to be returned as json object with data
#! @input escape_double_quotes: whether to escape  double Quotes in data default is null or Yes
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.SMAX.Operation
operation:
  name: SMAX_getEntityDetails
  inputs:
    - smax_url: "${get_sp('Cerner.DigitalFactory.SMAX.smaxURL')}"
    - smax_tenantId: "${get_sp('Cerner.DigitalFactory.SMAX.tenantID')}"
    - smax_auth_token
    - entity
    - query_field
    - entity_fields
    - escape_double_quotes:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to create/update/delete entity records\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   Operation: SMAX_getEntityDetails\r\n#   Inputs:\r\n#       -   smax_url\r\n#       -   smax_tenantId\r\n#       -   smax_auth_token\r\n#       -   entity\r\n#       -   query_field\r\n#       -   entity_fields\r\n#       -   escape_double_quotes\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   entity_data_json\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n#       -   errorProvder\r\n#       -   errorType\r\n#       -\r\n# Modified on 05 Aug 2022 by Rakesh Sharma for escape_double_quotes for so that json parser does not fail for addtional double quotes in the data\r\n# Modified on 07 Dec 2022 by Rakesh Sharma for retrieving addtional properties of linked field\r\n###############################################################\r\nimport json\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(smax_url, smax_auth_token, smax_tenantId, entity, query_field, entity_fields, escape_double_quotes):\r\n    message = \"\"\r\n    result = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    entity_data_json = \"\"\r\n    records = ''\r\n\r\n    try:\r\n        import json\r\n        import requests\r\n        queryKey = query_field.split(',')[0]\r\n        queryValue = query_field.split(',')[1]\r\n\r\n        url = smax_url + \"/rest/\" + smax_tenantId + \"/ems/\" + entity + \"?layout=\" + entity_fields\r\n        url += \"&filter=\" + queryKey + \"=\" + queryValue\r\n\r\n        payload = {}\r\n        headers = {\r\n            'Cookie': 'LWSSO_COOKIE_KEY=' + smax_auth_token,\r\n            'Content-Type': 'application/json',\r\n            'User-Agent': 'Apache-HttpClient/4.4.1'\r\n        }\r\n\r\n        response = requests.request(\"GET\", url, headers=headers,  data=payload)\r\n        message = response.text\r\n        mresponse = json.loads(response.text)\r\n\r\n        if response.status_code == 200:\r\n            if mresponse[\"meta\"][\"completion_status\"] == \"FAILED\":\r\n                msg = str(message)\r\n                raise Exception(msg)\r\n            if mresponse[\"meta\"][\"total_count\"] > 0 or mresponse[\"meta\"][\"completion_status\"] == \"OK\":\r\n                i = 0\r\n\r\n                entity_data_json = \"[\"\r\n                for rec in mresponse[\"entities\"]:\r\n                    entity_data_json += \"{\"\r\n                    for field in entity_fields.split(','):\r\n                        #tdata = str(rec[\"properties\"].get(field, \"\"))\r\n                        if '.' in field:\r\n                            tdata = str(rec[\"related_properties\"][field.split('.')[0]].get(field.split('.')[1], \"\"))\r\n                        else:\r\n                            tdata = str(rec[\"properties\"].get(field, \"\"))\r\n\r\n                        if escape_double_quotes.lower().strip() == 'yes':\r\n                            if len(tdata)>1000:\r\n                                tdata = tdata.replace('\\\\','\\\\\\\\')\r\n                            if '\\\\\"' not in tdata and '\"' in tdata:\r\n                                tdata = tdata.replace('\"', '\\\\\"')\r\n                            tdata = tdata.replace(\"\\\\'\", '').replace('||','\\\\\\|\\\\\\|').replace('\\|\\|','\\\\\\|\\\\\\|')\r\n                            entity_data_json += '\"' + field + '\":\"' + str(tdata) + '\",'\r\n\r\n                        else:\r\n                            entity_data_json += '\"' + field + '\":\"' + str(tdata) + '\",'\r\n\r\n                    entity_data_json = entity_data_json[:-1] + \"},\"\r\n                    i += 1\r\n                if entity_data_json[2:]:\r\n                    entity_data_json = entity_data_json[:-1] + \"]\"\r\n                    records = i\r\n                    message = \"Entity Details retrieved from SMAX \" + entity\r\n                else:\r\n                    entity_data_json = ''\r\n            else:\r\n                message = \"No Records found for given criteria from \" + entity\r\n            result = \"True\"\r\n        else:\r\n            msg = 'Cannot Open Connection to SMAX, Wrong URL or Wrong User password or SMAX not Available: ' + str(\r\n                response.text)\r\n            raise Exception(msg)\r\n    except Exception as e:\r\n        message = e\r\n        errorMessage = str(message) + ': http response: ' + str(response.text)\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'SMAX'\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"message\": message, \"records\": records, \"entity_data_json\": entity_data_json,\r\n            \"errorType\": errortype, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider}"
  outputs:
    - result
    - message
    - records
    - entity_data_json
    - errorMessage
    - errorSeverity
    - errorProvider
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
