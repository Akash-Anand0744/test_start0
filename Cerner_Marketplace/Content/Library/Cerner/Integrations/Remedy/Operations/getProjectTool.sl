########################################################################################################################
#!!
#! @input input_data: Comma separated Key Vlue pair with double Pipe (||) as record separator
#! @input project_tool: Key like remedy, jira, Abilities etc. to get its value
#!!#
########################################################################################################################
namespace: Cerner.Integrations.Remedy.Operations
operation:
  name: getProjectTool
  inputs:
    - input_data
    - project_tool
  python_action:
    use_jython: false
    script: "#######################\r\n#   Operation; getProjectTool\r\n#   Author: Rakesh Sharma\r\n#   Created on: 20 Sep 2022\r\n#   This Operation is for getting the Key (Project Tool) from a list of Comma separated Key Vlue pair with double Pipe (||) as record separator\r\n#\r\n#   INPUTS:\r\n#       input_data - Comma separated Key Vlue pair with double Pipe (||) as record separator\r\n#       project_tool  - Key like remedy, jira, Abilities etc. to get its value\r\n#\r\n#   OUTPUTS:\r\n#       message\r\n#       errorType\r\n#       key\r\n#       value\r\n#       result\r\n#\r\n#######################\r\n\r\ndef execute(input_data,project_tool):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n    key = ''\r\n    value = ''\r\n\r\n    try:\r\n        for data in input_data.split('||'):\r\n            if data and project_tool.lower() in data.lower():\r\n                key = data.split(',',1)[0]\r\n                value = data.split(',')[1]\r\n                message = 'Successfully retrieved the Key and Value for :' + project_tool\r\n                break\r\n            else:\r\n                key =''\r\n                value = ''\r\n                message = 'No Key or Value found for the Key: ' + project_tool\r\n        result = 'True'\r\n        \r\n    except Exception as e:\r\n        errorType = 'e10000'\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"key\": key, \"value\": value}"
  outputs:
    - result
    - message
    - errorType
    - key
    - value
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
