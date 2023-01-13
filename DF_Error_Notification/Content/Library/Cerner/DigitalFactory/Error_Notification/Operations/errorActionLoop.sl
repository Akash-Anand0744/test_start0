namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: errorActionLoop
  inputs:
    - actionsString
    - index: '0'
  python_action:
    use_jython: false
    script: "def execute(actionsString, index):\r\n    message = \"\"\r\n    result = \"False\"\r\n    nextIndex = \"-1\"\r\n    actionJson = \"\"\r\n    actionName = \"\"\r\n    actionParams = \"\"\r\n    \r\n    try:\r\n        import json\r\n        conf = json.loads(actionsString)\r\n        allActions = []\r\n        index = int(index)\r\n        for actions in conf:\r\n            for action in actions[\"actions\"]:\r\n                allActions.append(action)\r\n        \r\n        if len(allActions) > 0:\r\n            if (index > -1 and index < len(allActions)):\r\n                action = allActions[index]\r\n                actionName = action[\"action\"][\"handlerName\"]\r\n                try:\r\n                    for var in action[\"action\"][\"config\"][\"values\"]:\r\n                        actionParams += var[\"value\"][\"name\"] + \"♫\" + var[\"value\"][\"data\"] + \"♪\"\r\n                    if len(actionParams) > 0:\r\n                        actionParams = actionParams[:-1]\r\n                except:\r\n                    actionParams = \"\"\r\n                actionJson = json.dumps(action)\r\n                nextIndex = index + 1\r\n                result = \"True\"\r\n                if not (nextIndex > -1 and nextIndex < len(allActions)):\r\n                    nextIndex = -1\r\n                    #result = \"NoMore\"\r\n            else:\r\n                if index == -1:\r\n                    result = \"NoMore\"\r\n                else:\r\n                    message = \"Index Out of Bound!\"\r\n                    result = \"False\"\r\n        else:\r\n            message = \"No actions to execute!\"\r\n            result = \"False\"\r\n        \r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"nextIndex\": str(nextIndex), \"message\": message, \"actionJson\":actionJson, \"actionName\": actionName, \"actionParams\":actionParams }"
  outputs:
    - result
    - nextIndex
    - message
    - actionJson
    - actionName
    - actionParams
  results:
    - SUCCESS: '${result == "True"}'
    - NOMORE: '${result == "NoMore"}'
    - FAILURE
