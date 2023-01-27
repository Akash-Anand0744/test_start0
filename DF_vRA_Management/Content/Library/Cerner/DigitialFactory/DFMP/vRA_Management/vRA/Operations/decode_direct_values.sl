########################################################################################################################
#!!
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.vRA.Operations
operation:
  name: decode_direct_values
  inputs:
    - direct_values
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for to Decode the DIrect Values into the Parameters\r\n#   Operation: decode_direct_values\r\n#   Author: Rakesh Sharma (Rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       -   direct_values\r\n#\r\n#\r\n#   Outputs:\r\n#       -   result\r\n#       -   bearerToken\r\n#       -   message\r\n#       -   errorType\r\n#       -   errorMessage\r\n#       -   errorSeverity\r\n###############################################################\r\n\r\ndef execute(direct_values):\r\n    message = \"\"\r\n    result = \"False\"\r\n    key = \"\"\r\n    value = \"\"\r\n    errorType = \"\"\r\n    StartDate = \"\"\r\n    EndDate = \"\"\r\n    DeploymentName = \"\"\r\n    Version = \"\"\r\n    DeployUser = \"\"\r\n    Password = \"\"\r\n    os_type = \"\"\r\n\r\n    try:\r\n\r\n        if direct_values:\r\n            datas = direct_values.split(\"||\")\r\n\r\n            for data in datas:\r\n                if data:\r\n                    key = data.split(',')[0].strip().strip('_c')\r\n                    value = data.split(',', 1)[1].strip()\r\n\r\n                    if key == 'StartDate':\r\n                        StartDate = value\r\n                    if key == 'EndDate':\r\n                        EndDate = value\r\n                    if key == 'DeploymentName':\r\n                        DeploymentName = value\r\n                    if key == 'Version':\r\n                        Version = value\r\n                    if key == 'DeployUser':\r\n                        DeployUser = value\r\n                    if key == 'Password':\r\n                        Password = value\r\n                    if key.lower() == 'ostype':\r\n                        os_type = value\r\n        else:\r\n            message = 'No Data To Process, provided input is empty'\r\n        result = \"True\"\r\n\r\n    except Exception as e:\r\n        errorType = 'e10000'\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"StartDate\": StartDate, \"EndDate\": EndDate,\r\n            \"DeploymentName\": DeploymentName, \"Version\": Version, \"DeployUser\": DeployUser, \"Password\": Password,\"os_type\":os_type,\r\n            \"errorType\": errorType}"
  outputs:
    - result
    - message
    - StartDate
    - EndDate
    - DeploymentName
    - Version
    - DeployUser
    - Password
    - os_type
    - errorType
  results:
    - SUCCESS: '${result == "True"}'
      CUSTOM_0: '${result == "name"}'
    - FAILURE
