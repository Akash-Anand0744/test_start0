namespace: Cerner.DigitalFactory.MarketPlace.OO.Operation
operation:
  name: CreateAlertBody
  inputs:
    - central_url
    - flows_list_json: ''
    - signature: "${get_sp('Cerner.DigitalFactory.Error_Notification.signature')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n# Operation: CreateLaertBody\r\n#  \r\n#   Author: Rakesh Sharma Cerner (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       - flows_list_json\r\n#  \r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - operator_email\r\n#       - errorType\r\n#       - errorMessage\r\n#   Created On:12 Jan 2022\r\n#  -------------------------------------------------------------\r\n###############################################################\r\n\r\ndef execute(central_url, flows_list_json,signature):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    alert_body = \"\"\r\n\r\n    try:\r\n        import json\r\n        alert_body = '<html><head>'\r\n        alert_body += '<style> table, th, td {   border:1px solid black;   border-collapse: collapse; }</style>'\r\n        alert_body = '</head> <body><p>Dear Operator,<br><br>Below is the list of <b>Failed to Complete</b> OO Flows:'\r\n        alert_body += '<table>  <tr> <th style=\"width:40px\">OO Run ID</th>   <th style=\"width:40px\">Flow Status</th> <th style=\"width:40px\">Run Time(CST)</th> <th>Run Name</th></tr>'\r\n        \r\n        flows = json.loads(flows_list_json)\r\n        \r\n        for flow in flows:\r\n            if flow:\r\n                run_id = flow[\"executionId\"]\r\n                run_time = flow[\"startTime\"]\r\n                run_status = flow[\"status\"]\r\n                run_name = flow[\"executionName\"]\r\n                cst_dt = unixToCSTDate(run_time)\r\n                run_time = cst_dt[\"cst_date\"].split(\"CST\")[0]\r\n                run_id = '<a href=\"{0}/#/runtimeWorkspace/runs/{1}\"> {1}</a>'.format(central_url,run_id)\r\n                \r\n                alert_body += '<tr><td>{0}</td><td>{1}</td> <td>{2}</td><td>{3}</td> </tr>'.format(run_id,run_status,run_time,run_name)\r\n        alert_body += '</table>'\r\n        alert_body += '<br> Kindly fix the failures and validate the services.<br><br>Yours Sincerely,<br>'\r\n        alert_body += signature + '<br> ----------------------------------------------------------------'\r\n            \r\n\r\n        result = \"True\"\r\n        message = \"Operator email body succesfully created\"\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"alert_body\": alert_body, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}\r\n##Fucntion to convert UNix TS to CST Time\r\ndef unixToCSTDate(dt):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    cst_date = ''\r\n\r\n    try:\r\n        from datetime import datetime\r\n        import pytz\r\n        dt = str(dt)[:10]\r\n        dt = int(dt)\r\n        tt = datetime.fromtimestamp(dt)\r\n        YY = tt.strftime(\"%Y\")\r\n        MM = tt.strftime(\"%m\")\r\n        DD = tt.strftime(\"%d\")\r\n        HH = tt.strftime(\"%H\")\r\n        MI = tt.strftime(\"%M\")\r\n        SS = tt.strftime(\"%S\")\r\n        utc_date = datetime(int(YY), int(MM), int(DD), int(HH), int(MI), int(SS), tzinfo = pytz.utc)\r\n\r\n        cst_date = utc_date.astimezone(pytz.timezone('US/Central')).strftime('%Y-%m-%d %H:%M:%S %Z%z')\r\n\r\n        \r\n        message = cst_date\r\n        result = 'True'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message,  \"cst_date\": cst_date, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - alert_body
    - result
    - message
    - errorType
    - errorMessage
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
