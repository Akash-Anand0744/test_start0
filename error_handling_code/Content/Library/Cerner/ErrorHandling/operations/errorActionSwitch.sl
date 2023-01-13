namespace: Cerner.ErrorHandling.operations
operation:
  name: errorActionSwitch
  inputs:
    - actionName
    - actionParams
    - pramMapping: "${get_sp('Cerner.ErrorHandling.parameterMapping')}"
    - loggerName: "${get_sp('Cerner.ErrorHandling.loggerName')}"
    - emailerName: "${get_sp('Cerner.ErrorHandling.emailerName')}"
    - incidentCreatorName: "${get_sp('Cerner.ErrorHandling.incidentCreatorName')}"
    - monitoringTriggerName: "${get_sp('Cerner.ErrorHandling.monitoringTriggerName')}"
  python_action:
    use_jython: false
    script: "def execute(actionName, actionParams, pramMapping, loggerName, emailerName, incidentCreatorName, monitoringTriggerName):\r\n    message = \"\"\r\n    result = \"False\"\r\n    param = [\"\"]*5\r\n\r\n    try:\r\n        mapIndex = 0\r\n        if actionName.lower() == loggerName.lower():\r\n            result = \"logger\"\r\n            mapIndex = 0\r\n        if actionName.lower() == emailerName.lower():\r\n            result = \"email\"\r\n            mapIndex = 1\r\n        if actionName.lower() == incidentCreatorName.lower():\r\n            result = \"incident\"\r\n            mapIndex = 2\r\n        if actionName.lower() == monitoringTriggerName.lower():\r\n            result = \"monitor\"\r\n            mapIndex = 3\r\n\r\n        pramMapping = pramMapping.split(\";\")[mapIndex]\r\n        i = 0\r\n        for varname in pramMapping.split(\",\"):\r\n            found = False\r\n            for paramvar in actionParams.split(\"♪\"):\r\n                paramvarArr = paramvar.split(\"♫\")\r\n                if (paramvarArr[0] == varname):\r\n                    param[i] = paramvarArr[1]\r\n            i+=1\r\n            if i > 4:\r\n                break\r\n        \r\n        \r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"params\":actionParams, \"param1\": param[0], \"param2\": param[1], \"param3\": param[2], \"param4\": param[3], \"param5\": param[4] }"
  outputs:
    - result
    - message
    - params
    - param1
    - param2
    - param3
    - param4
    - param5
  results:
    - LOGGER: '${result == "logger"}'
    - EMAILER: '${result == "email"}'
    - INCIDENT: '${result == "incident"}'
    - MONITOR: '${result == "monitor"}'
    - FAILURE
