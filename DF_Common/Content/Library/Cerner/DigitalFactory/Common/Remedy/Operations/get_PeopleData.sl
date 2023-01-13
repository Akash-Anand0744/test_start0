########################################################################################################################
#!!
#! @input people_field: Available values are peopleId,firstName, lastName,jobTitle,corporateId,site, etc.
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.Remedy.Operations
operation:
  name: get_PeopleData
  inputs:
    - rapid_url: "${get_sp('Cerner.DigitalFactory.Remedy.rapidURL')}"
    - rapid_token
    - associate_id
    - people_field: peopleId
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation to get the Rapid API Token for Remedy Operations\r\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\r\n#   operation: get_PeopleData\r\n#   Created on 20 Sep 2022\r\n#   Inputs:\r\n#       -   rapid_url\r\n#       -   rapid_token\r\n#       -   associate_id\r\n#       -   people_field -- Available values are peopleId,firstName, lastName,jobTitle,corporateId,site, etc.\r\n\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   data\r\n#       -   errortype\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n#       -   errorProvider\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\n\r\n\r\ndef execute(rapid_url, rapid_token, associate_id, people_field):\r\n    message = \"\"\r\n    result = \"\"\r\n    token = \"\"\r\n    errortype = \"\"\r\n    errorMessage = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    data = ''\r\n\r\n    try:\r\n        import requests\r\n        import json\r\n        payload = \"\"\r\n        headers = {\r\n            'Content-Type': 'application/json',\r\n            'Authorization': 'Bearer ' + rapid_token\r\n        }\r\n\r\n        url = rapid_url + '/remedy-people-query-svc/v2/people?corporateId=' + associate_id.split('@')[0]\r\n\r\n        response = requests.request(\"GET\", url, headers=headers, data=payload)\r\n\r\n        if response.status_code == 200:\r\n            tresponse = json.loads(response.content)\r\n            data = tresponse[\"content\"][0][people_field]\r\n            result = \"True\"\r\n        else:\r\n            message = str(response.text) + ': Response code: ' + str(response.status_code)\r\n            raise Exception(message)\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        errorMessage = message\r\n        errortype = 'e20000'\r\n        result = \"False\"\r\n        errorProvider = 'RAPID'\r\n        errorSeverity = \"ERROR\"\r\n\r\n    return {\"result\": result, \"data\": data, \"message\": message, \"errorType\": errortype, \"errorMessage\": errorMessage,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider}"
  outputs:
    - result
    - message
    - data
    - errorType
    - errorProvider
    - errorMessage
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
