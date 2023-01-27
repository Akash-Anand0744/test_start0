########################################################################################################################
#!!
#! @input jira_align_host: JIRA Align Host
#! @input token: Authorization token
#! @input jira_align_protocol: http or https
#! @input api_url: API URL of the service excluding the host
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA_ALIGN.Operation
operation:
  name: Get_JiraAlign_IdDescription_JSON
  inputs:
    - jira_align_host: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.jira_align_host')}"
    - token: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.token')}"
    - jira_align_protocol: "${get_sp('Cerner.DigitalFactory.JIRA_ALIGN.protocol')}"
    - api_url
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for Generating JSON object from JIRA Align for API URL\r\n#   Provided for example Planning Groups or Portfolio Groups\r\n#   Author: Rakesh Sharma Cerner (rakesh.sharma@cerner.com)\r\n#  Operation : Get_JiraAlign_IdTitleDescription_JSON\r\n#   Inputs:\r\n#       - jira_align_host\r\n#       - token\r\n#       - jira_align_protocol\r\n#       - api_url\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - errorType\r\n#       - errorSeverity\r\n#       - errorProvider\r\n#       - errorMessage\r\n#   Created On:27 Dec 2021\r\n#   Modified on 08 Jun 2022 by Rakesh Sharma to fetch more than 100 records through second iteration.\r\n#  -------------------------------------------------------------\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(jira_align_host, token, jira_align_protocol, api_url):\r\n    result = \"False\"\r\n    errorType = ''\r\n    errorMessage = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    message = ''\r\n    return_json = ''\r\n    id_list = ''\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n\r\n        i = 0\r\n        while i < 2:\r\n            if i == 0:\r\n                skip = 0\r\n            elif i == 1:\r\n                skip = 100\r\n\r\n            turl = '{0}://{1}{2}?skip={3}'.format(jira_align_protocol, jira_align_host, api_url, skip)\r\n            payload = {}\r\n            headers = {\r\n                'Authorization': 'Bearer {0}'.format(token)\r\n            }\r\n\r\n            # headers = {'X-Atlassian-Token': 'no-check'}\r\n            response = requests.request(\"GET\", turl, headers=headers, data=payload)\r\n\r\n            if response.status_code == 200:\r\n                json_array = json.loads(response.content)\r\n                for group in json_array:\r\n                    id_gp = group[\"id\"]\r\n                    title = group[\"name\"]\r\n                    ttdesc = group[\"name\"]\r\n                    update_date = group[\"lastUpdatedDate\"]\r\n                    id_list += str(id_gp) + ','\r\n                    return_json += '{ \"id\":\"' + str(id_gp) + '\",\"title\":\"' + title + '\",\"description\":\"' + str(\r\n                        ttdesc) + '\",\"update_date\":\"' + str(update_date) + '\"},'\r\n            else:\r\n                msg = 'Invalid response from the Provider, Response Status Code: ' + str(response.status_code) + ': ' + str(response.text)\r\n                raise Exception(msg)\r\n\r\n            i = i + 1\r\n        id_list = id_list[:-1]\r\n        # id_list = \"[\" + id_list + \"]\"\r\n        return_json = return_json[:-1]\r\n        return_json = '[' + return_json + ']'\r\n        result = \"True\"\r\n        message = 'Successfully retrieved and converted to json  object'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e20000\"\r\n        errorMessage = message\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"JIRA_ALIGN\"\r\n\r\n    return {\"result\": result, \"message\": message, \"return_json\": return_json, \"id_list\": id_list,\r\n            \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}"
  outputs:
    - return_json
    - id_list
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
