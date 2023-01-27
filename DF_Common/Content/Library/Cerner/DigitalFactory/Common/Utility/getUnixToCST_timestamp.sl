########################################################################################################################
#!!
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.Utility
operation:
  name: getUnixToCST_timestamp
  inputs:
    - dt
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   Opertion Name: getOOLastruntime\r\n#   OO operation for getting the last successful run time based on Flow Run Name\r\n#   Author: Ashwini Shalke (ashwini.shalke@cerner.com)\r\n#   Inputs:\r\n#       -   unix_timestamp\r\n#\r\n#   Outputs:\r\n#       -   cst_timestamp\r\n#   CreateDate:- 7/04/2022\r\n# this operation will convert UNIX timestamp into CST timestamp\r\n###############################################################\r\n\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    errorMessage = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = \"e10000\"\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorMessage\": errorMessage}\r\n    \r\n\r\n# requirement external modules\r\ninstall(\"requests\")\r\ninstall(\"pytz\")\r\n\r\n\r\n\r\ndef execute(dt):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    errorSeverity = ''\r\n    errorProvider = ''\r\n    cst_date = ''\r\n\r\n    try:\r\n        from datetime import datetime\r\n        import pytz\r\n        dt = str(dt)[:10]\r\n        dt = int(dt)\r\n        tt = datetime.fromtimestamp(dt)\r\n        YY = tt.strftime(\"%Y\")\r\n        MM = tt.strftime(\"%m\")\r\n        DD = tt.strftime(\"%d\")\r\n        HH = tt.strftime(\"%H\")\r\n        MI = tt.strftime(\"%M\")\r\n        SS = tt.strftime(\"%S\")\r\n        utc_date = datetime(int(YY), int(MM), int(DD), int(HH), int(MI), int(SS), tzinfo = pytz.utc)\r\n\r\n        cst_date = utc_date.astimezone(pytz.timezone('US/Central')).strftime('%Y-%m-%d %H:%M:%S %Z%z')\r\n\r\n        \r\n        message = cst_date\r\n        result = 'True'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n        errorSeverity = 'ERROR'\r\n        errorProvider = 'OOExec'\r\n        \r\n    return {\"result\": result, \"message\": message,  \"cst_date\": cst_date, \"errorType\": errorType,\"er,rorSeverity\":errorSeverity,\"errorProvider\":errorProvider,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - message
    - result
    - cst_date
    - errorType
    - errorMessage
    - errorProvider
    - errorSeverity
  results:
    - SUCCESS: '${result == "True"}'
    - FAILURE
