namespace: Cerner.DFMP.Error_Framework.Operations
operation:
  name: formatErrorMessage
  inputs:
    - input_data
  python_action:
    use_jython: false
    script: "#######################\r\n#   Operation; formatErrorMessage\r\n#   Author: Rakesh Sharma\r\n#   Created on: 19 Sep 2022\r\n#   This Operation is for formatting the errormessage data in the ErrorLogs Format so that it can be in teh JSON format properly and can be saved in the Error Losg Tracker\r\n#\r\n#   INPUTS:\r\n#       input_data\r\n#\r\n#   OUTPUTS:\r\n#       data\r\n#\r\n#\r\n#\r\n#\r\n#\r\n#######################\r\n\r\ndef execute(input_data):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorType = \"\"\r\n\r\n    index_string = '||ErrorMessage'\r\n\r\n    try:        \r\n        s_index = input_data.index(index_string)\r\n        pre_data = input_data[:s_index]\r\n        post_data = input_data[s_index + len(index_string):].replace('||', '\\\\|\\\\|')\r\n        data = pre_data + index_string + post_data\r\n        message = 'Successfully formatted ErrorMessage'\r\n        result = 'True'\r\n    except Exception as e:\r\n        errorType = 'e10000'\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"data\": data, \"errorType\": errorType}"
  outputs:
    - result
    - message
    - data
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
