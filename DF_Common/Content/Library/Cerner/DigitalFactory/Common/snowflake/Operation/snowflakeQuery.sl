########################################################################################################################
#!!
#! @description: This Operation will connect to the MS SQL Server Database and Fetch SQL query Values and return JSON Object.
#!                
#!               All the Query output  headers will be in lower case
#!
#! @input sqlQuery: Provide a valid Query. Its Output headers will be in lower case
#!
#! @output output_json: JSON Object Output, query output  headers in lower case
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.snowflake.Operation
operation:
  name: snowflakeQuery
  inputs:
    - snowflake_user: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_user')}"
    - snowflake_db: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_db')}"
    - snowflake_account: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_account')}"
    - snowflake_Password: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_password')}"
    - sqlQuery
    - previous_errorLogs:
        required: false
    - snowflake_schema: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_schema')}"
    - snowflake_role: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_role')}"
    - snowflake_warehouse: "${get_sp('Cerner.DigitalFactory.snowflake.snowflake_warehouse')}"
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for Running snowflake Query and return JSON object\r\n#   Author: Jonathan Acosta (jonathan.acosta@cerner.com)\r\n#   Operation: snowflakeQuery\r\n#   Inputs:\r\n#       -  snowflake_user\r\n#       -  snowflake_db\r\n#       -  snowflake_account\r\n#       -  snowflake_Password\r\n#       -  sqlQuery\r\n#       -  snowflake_schema\r\n#       -  snowflake_role\r\n#       -  snowflake_warehouse\r\n#       -  previous_errorLogs\r\n#   Outputs:\r\n#       -   result\r\n#       -   message\r\n#       -   errorType\r\n#       -   output_json\r\n#       -   errorLogs\r\n#       -   errorMessage\r\n#       -   errorProvider\r\n#       -   errorSeverity\r\n###############################################################\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorType = \"\"\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message}\r\n\r\n\r\n# requirement external modules\r\ninstall(\"snowflake-connector-python\")\r\n\r\n\r\n# main function called by OO scheduler\r\ndef execute(snowflake_user, snowflake_db, snowflake_account, snowflake_Password, sqlQuery,snowflake_schema,snowflake_role,snowflake_warehouse,previous_errorLogs):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorSeverity = \"\"\r\n    errorType = \"\"\r\n    errorProvider = \"\"\r\n    errorMessage = \"\"\r\n    output_json = \"\"\r\n    errorLogs = \"\"\r\n    conn = \"\"\r\n\r\n    try:\r\n        import json\r\n        from snowflake.connector import connect\r\n\r\n        sqlFields = sqlQuery.lower().strip('select').strip(' distinct').split('from')[0].split(',')\r\n        countFields = len(sqlFields)\r\n        sqlQuery = sqlQuery.lower()\r\n\r\n        i = 0\r\n        # connect to  database and extract the values list\r\n        conn = connect(user=snowflake_user, password=snowflake_Password, account=snowflake_account, warehouse=snowflake_warehouse,  database=snowflake_db, schema=snowflake_schema,role=snowflake_role)\r\n        cursor = conn.cursor()\r\n        cursor.execute(sqlQuery)\r\n        for row in cursor:\r\n            output_json += '{'\r\n            f=0\r\n            for field in sqlFields:\r\n                if ' as' in field:\r\n                    field = field.split(' as ')[1].strip()\r\n                else:\r\n                    field = field.strip()\r\n                value = row[f]\r\n                f=f+1\r\n                output_json += '\"' + field + '\":\"' + str(value) + '\",'\r\n            output_json = output_json[:-1] + '},'\r\n\r\n            i += 1\r\n        if i > 0:\r\n            output_json = \"[\" + output_json[:-1] + \"]\"\r\n            result = 'True'\r\n            message = 'Data retrieved successfully from DB'\r\n        else:\r\n            result = 'True'\r\n            message = 'Found no records from the provided query'\r\n\r\n    except Exception as e:\r\n        \r\n        message = str(e)\r\n        result = \"False\"\r\n        errorSeverity = \"ERROR\"\r\n        errorType = \"e20000\"\r\n        errorProvider = \"snowflake\"\r\n        errorMessage = message\r\n        errorLogs = \"ProviderUrl,\" + str(conn) + \"||ErrorProvider,snowflake||ProviderUrlBody,||ErrorMessage,\" + str(message) + \"|||\"\r\n        \r\n        \r\n    return {\"result\": result, \"message\": message, \"output_json\": output_json, \"errorType\": errorType, \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider, \"errorMessage\": errorMessage,\"errorLogs\":errorLogs + previous_errorLogs}"
  outputs:
    - result
    - message
    - output_json
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
    - errorLogs
  results:
    - SUCCESS: "${result == 'True'}"
    - FAILURE
