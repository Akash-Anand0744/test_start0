namespace: Cerner.DigitalFactory.Common.snowflake.Operation
operation:
  name: tableCreator
  inputs:
    - output_json
    - output_json_table
    - previous_errorLogs:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#set table in Format HTML using the field names as headers and  let the data in the field description\r\n#   Author: Jonathan Acosta (jonathan.acosta@cerner.com)\r\n#   Operation: snowflakeQuery\r\n#   Inputs:\r\n#       -  output_json\r\n#       -  output_json_table\r\n#\r\n#   Outputs:\r\n#       -   jsonTable\r\n#       -   message\r\n#       -   errorType\r\n#       -   result\r\n#       -   errorLogs\r\n#       -   errorMessage\r\n#       -   errorProvider\r\n#       -   errorSeverity\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\nimport requests\r\n\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    try:\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n    \r\n\r\ndef execute(output_json,output_json_table,previous_errorLogs):\r\n    install(\"requests\")\r\n    \r\n    result = \"False\"\r\n    message= \"\"\r\n    errorProvider = \"\"\r\n    errorMessage = \"\"\r\n    jsonTable = \"\"\r\n    errorSeverity= \"\"\r\n    errorType = \"\"\r\n    errorLogs = \"\"\r\n   \r\n    try:\r\n        import json\r\n        output_json = json.loads(output_json)\r\n        output_json_table = json.loads(output_json_table)\r\n        for item in output_json:\r\n            id_gp = item[\"id\"]\r\n            table=''\r\n            \r\n            for recordTable in output_json_table:\r\n                id_rp = recordTable[\"id\"]\r\n                if id_gp == id_rp:\r\n                    \r\n                    #use to create the headers of the table\r\n                    if table=='':\r\n                        table='<table border=&amp;quot;1&amp;quot; cellpadding=&amp;quot;1&amp;quot; cellspacing=&amp;quot;1&amp;quot; style=&amp;quot;width:500px&amp;quot;><tbody><tr>'\r\n                        for key in recordTable.keys():\r\n                            if str(key)!='Id':\r\n                                \r\n                                if str(key).replace('_',' ')!= '':\r\n                                    table+='<td><strong>'+str(key).replace('_',' ') +'</strong></td>'    \r\n                                else :\r\n                                    table+='<td><strong>'+key +'</strong></td>'\r\n                        table+='</tr><tr>'\r\n                    for values in recordTable:    \r\n                        if str(values)!='Id':\r\n                            table+='<td>'+str(recordTable[values])+'</td>'\r\n                            result = \"True\"\r\n                    table+='</tr><tr>'\r\n            if table!='':\r\n                table+='</tr></tbody></table><p></p>'\r\n            if table=='':\r\n                table='No service details currently available'\r\n            item[\"description\"]=table\r\n        jsonTable = json.dumps(output_json)\r\n    except Exception as e:\r\n        \r\n        message = str(e)\r\n        result = \"False\"\r\n        errorSeverity = \"ERROR\"\r\n        errorType = \"e20000\"\r\n        errorProvider = \"snowflake\"\r\n        errorMessage = message\r\n        errorLogs = \"||ErrorProvider,snowflake||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\r\n    \r\n    \r\n    return {\"jsonTable\" : jsonTable,\"result\": result, \"message\": message, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage , \"errorSeverity\": errorSeverity,  \"errorType\": errorType,\"errorLogs\":errorLogs + previous_errorLogs}"
  outputs:
    - result
    - message
    - errorProvider
    - errorMessage
    - jsonTable
    - errorSeverity
    - errorType
    - errorLogs
  results:
    - SUCCESS: "${result == 'True'}"
    - FAILURE
