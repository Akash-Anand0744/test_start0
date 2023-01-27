########################################################################################################################
#!!
#! @input input_list: Key Value Pair separated by double pipe "||"
#!!#
########################################################################################################################
namespace: Cerner.DigitialFactory.DFMP.vRA_Management.Notification.Operations
operation:
  name: CreateBody_VMDeployed
  inputs:
    - first_line_body
    - input_list
    - signature: "${get_sp('Cerner.DigitalFactory.Error_Notification.signature')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n# Operation: CreateBody_VMDeployed\r\n#\r\n#   Author: Rakesh Sharma Cerner (rakesh.sharma@cerner.com)\r\n#   Inputs:\r\n#       - input_list\r\n#       - signature\r\n#\r\n#   Outputs:\r\n#       - mail_body\r\n#       - result\r\n#       - message\r\n#       - message\r\n#       - errorType\r\n#       - errorMessage\r\n#   Created On:14 Feb 2022\r\n#  -------------------------------------------------------------\r\n###############################################################\r\n\r\ndef execute(first_line_body,input_list, signature):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    mail_body = \"\"\r\n\r\n    try:\r\n        import json\r\n        mail_body = '<html><head>'\r\n        mail_body += '<style> table, th, td {   border:1px solid black;   border-collapse: collapse; }</style>'\r\n        mail_body += '</head> <body><p>Dear Requestor,<br><br>' +  first_line_body + '<br><br>'\r\n        mail_body += 'Below are the deployment details: <br>'\r\n        mail_body += '<table>  <tr> <th style=\"width:50px\">Description</th>   <th style=\"width:70%\">Information</th>'\r\n\r\n        for data in input_list.split(\"||\"):\r\n            if data:\r\n                key = data.split(',')[0].strip()\r\n                value = data.split(',')[1].strip()\r\n                if value:\r\n                    mail_body += '<tr><td>{0}</td><td>{1}</td> </tr>'.format(key, value)\r\n        mail_body += '</table>'\r\n        mail_body += '<br><br>Yours Sincerely,<br>'\r\n        mail_body += signature + '<br> ----------------------------------------------------------------'\r\n        mail_body += '</body></html>'\r\n\r\n        result = \"True\"\r\n        message = \"Requestor email body succesfully created\"\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"mail_body\": mail_body, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}\r\n\r\n\r\n##Fucntion to convert UNix TS to CST Time\r\ndef unixToCSTDate(dt):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    cst_date = ''\r\n\r\n    try:\r\n        from datetime import datetime\r\n        import pytz\r\n        dt = str(dt)[:10]\r\n        dt = int(dt)\r\n        tt = datetime.fromtimestamp(dt)\r\n        YY = tt.strftime(\"%Y\")\r\n        MM = tt.strftime(\"%m\")\r\n        DD = tt.strftime(\"%d\")\r\n        HH = tt.strftime(\"%H\")\r\n        MI = tt.strftime(\"%M\")\r\n        SS = tt.strftime(\"%S\")\r\n        utc_date = datetime(int(YY), int(MM), int(DD), int(HH), int(MI), int(SS), tzinfo=pytz.utc)\r\n\r\n        cst_date = utc_date.astimezone(pytz.timezone('US/Central')).strftime('%Y-%m-%d %H:%M:%S %Z%z')\r\n\r\n        print(cst_date)\r\n        message = cst_date\r\n        result = 'True'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"cst_date\": cst_date, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - mail_body
    - result
    - message
    - errorType
    - errorMessage
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
