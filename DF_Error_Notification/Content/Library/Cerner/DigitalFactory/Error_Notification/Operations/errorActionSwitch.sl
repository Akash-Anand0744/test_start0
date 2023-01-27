########################################################################################################################
#!!
#! @output param1: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[0]
#! @output param2: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[1]
#! @output param3: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[2]
#! @output param4: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[3]
#! @output param5: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[4]
#! @output param6: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[5]
#! @output param7: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[6]
#! @output param8: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[7]
#! @output param9: parameter value defined by config Cerner.DigitalFactory.Error_Notification.parameterMapping[8]
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: errorActionSwitch
  inputs:
    - actionName
    - actionParams:
        required: false
        default: ''
    - pramMapping: "${get_sp('Cerner.DigitalFactory.Error_Notification.parameterMapping')}"
    - loggerName: "${get_sp('Cerner.DigitalFactory.Error_Notification.loggerName')}"
    - emailerName: "${get_sp('Cerner.DigitalFactory.Error_Notification.emailerName')}"
    - incidentCreatorName: "${get_sp('Cerner.DigitalFactory.Error_Notification.incidentCreatorName')}"
    - monitoringTriggerName: "${get_sp('Cerner.DigitalFactory.Error_Notification.monitoringTriggerName')}"
    - smaxErrorInputName: "${get_sp('Cerner.DigitalFactory.Error_Notification.smaxErrorHandlerName')}"
  python_action:
    use_jython: false
    script: "def execute(actionName, actionParams, pramMapping, loggerName, emailerName, incidentCreatorName, monitoringTriggerName, smaxErrorInputName):\r\n    message = \"\"\r\n    result = \"False\"\r\n    param = [\"\"]*10\r\n\r\n    try:\r\n        mapIndex = 0\r\n        if actionName.lower() == loggerName.lower():\r\n            result = \"logger\"\r\n            mapIndex = 0\r\n        if actionName.lower() == emailerName.lower():\r\n            result = \"email\"\r\n            mapIndex = 1\r\n        if actionName.lower() == incidentCreatorName.lower():\r\n            result = \"incident\"\r\n            mapIndex = 2\r\n        if actionName.lower() == monitoringTriggerName.lower():\r\n            result = \"monitor\"\r\n            mapIndex = 3\r\n        if actionName.lower() == smaxErrorInputName.lower():\r\n            result = \"smax_error\"\r\n            mapIndex = 4\r\n\r\n        pramMapping = pramMapping.split(\";\")[mapIndex]\r\n        i = 0\r\n        if len(actionParams)>0:\r\n            for varname in pramMapping.split(\",\"):\r\n                found = False\r\n                for paramvar in actionParams.split(\"♪\"):\r\n                    paramvarArr = paramvar.split(\"♫\")\r\n                    if (paramvarArr[0] == varname):\r\n                        param[i] = paramvarArr[1]\r\n                i+=1\r\n                if i > 8:\r\n                    break\r\n        \r\n        \r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"params\":actionParams, \"param1\": param[0], \"param2\": param[1], \"param3\": param[2], \"param4\": param[3], \"param5\": param[4], \"param6\": param[5], \"param7\": param[6], \"param8\": param[7], \"param9\": param[8] }"
  outputs:
    - result
    - message
    - params
    - param1
    - param2
    - param3
    - param4
    - param5
    - param6
    - param7
    - param8
    - param9
  results:
    - LOGGER: '${result == "logger"}'
    - EMAILER: '${result == "email"}'
    - INCIDENT: '${result == "incident"}'
    - MONITOR: '${result == "monitor"}'
    - SMAX_ERROR: '${result == "smax_error"}'
    - FAILURE
