########################################################################################################################
#!!
#! @input spl_chars: Special Characters that should be converted to JIRA format
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Common.JIRA.Operation
operation:
  name: extractKeyTpe
  inputs:
    - jirafieldkey
    - jirafieldvalue
    - spl_chars:
        required: false
        default: "${get_sp('MarketPlace.Special_Characters')}"
  python_action:
    use_jython: false
    script: "def execute(jirafieldkey, jirafieldvalue, spl_chars):\r\n    message = \"\"\r\n    result = \"False\"\r\n    key = \"\"\r\n    keyType = \"\"\r\n    value = jirafieldvalue.strip()\r\n    valueType = \"\"\r\n    errorType = \"\"\r\n    errorProvider = \"\"\r\n\r\n    try:\r\n        import re\r\n\r\n        # regexp = re.compile('[@_\\n\\t\\r!#$%^&*()<>?/\\|}{~:;’‘`\"]')\r\n\r\n        # spl_chars = '\\t\\n\\r'\r\n        RE_SPL_CHARS = '[@_!#$%^&*()<>?/\\|}{~:;’‘’`\"' + spl_chars + ']'\r\n        regexp = re.compile(RE_SPL_CHARS)\r\n\r\n        if value[0] == '[' and value[-1] == ']':\r\n            value = value[1:-1]\r\n\r\n        if regexp.search(value):\r\n            valueType = 'rich'\r\n        elif value.find(\"'\") != -1:\r\n            valueType = 'rich'\r\n        elif value.find(\"\\\\\") != -1:\r\n            valueType = 'rich'\r\n\r\n        if jirafieldkey.startswith('value.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('value.')[1]\r\n            keyType = 'value'\r\n\r\n        elif jirafieldkey.startswith('arraystring.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('arraystring.')[1]\r\n            keyType = 'arraystring'\r\n        elif jirafieldkey.startswith('array.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('array.')[1]\r\n            keyType = 'array'\r\n        elif jirafieldkey.startswith('nameobject.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('nameobject.')[1]\r\n            keyType = 'nameobject'\r\n        elif jirafieldkey.startswith('name.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('name.')[1]\r\n            keyType = 'name'\r\n        elif jirafieldkey.startswith('rich.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('rich.')[1]\r\n            keyType = 'rich'\r\n            valueType = 'rich'\r\n        elif jirafieldkey.startswith('date.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('date.')[1]\r\n            keyType = 'default'\r\n            cst_dt = unixToCSTDate(jirafieldvalue)\r\n            # value = cst_dt[\"cst_date\"].split(\"CST\")[0].strip()\r\n            value = cst_dt[\"cst_date\"]\r\n        elif jirafieldkey.find('.') == -1:\r\n            result = \"True\"\r\n            key = jirafieldkey\r\n            keyType = 'default'\r\n        elif jirafieldkey.startswith('nested.'):\r\n            result = \"True\"\r\n            key = jirafieldkey.split('nested.')[1]\r\n            keyType = 'nested'\r\n        else:\r\n            msg = 'Provided Jira field Key name is not in proper format: ' + jirafieldkey\r\n            raise Exception(msg)\r\n\r\n    except Exception as e:\r\n        errorProvider = \"OOExec\"\r\n        errorType = 'e10000'\r\n        message = str(e)\r\n        result = \"False\"\r\n    return {\"result\": result, \"message\": message, \"key\": key, \"keyType\": keyType, \"valueType\": valueType,\r\n            \"value\": value, \"errorType\": errorType}\r\n\r\n\r\ndef unixToCSTDate(dt):\r\n    message = \"\"\r\n    result = \"False\"\r\n    errorMessage = ''\r\n    errorType = ''\r\n    cst_date = ''\r\n\r\n    try:\r\n        from datetime import datetime\r\n        import pytz\r\n        dt = str(dt)[:10]\r\n        dt = int(dt)\r\n        tt = datetime.fromtimestamp(dt)\r\n        YY = tt.strftime(\"%Y\")\r\n        MM = tt.strftime(\"%m\")\r\n        DD = tt.strftime(\"%d\")\r\n        HH = tt.strftime(\"%H\")\r\n        MI = tt.strftime(\"%M\")\r\n        SS = tt.strftime(\"%S\")\r\n        utc_date = datetime(int(YY), int(MM), int(DD), int(HH), int(MI), int(SS), tzinfo=pytz.utc)\r\n\r\n        # cst_date = utc_date.astimezone(pytz.timezone('US/Central')).strftime('%Y-%m-%d %H:%M:%S.%f %Z%z')\r\n        cst_date = utc_date.astimezone(pytz.timezone('US/Central')).strftime('%Y-%m-%dT%H:%M:%S.00%z')\r\n\r\n        print(cst_date)\r\n        message = cst_date\r\n        result = 'True'\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorType = 'e10000'\r\n        errorMessage = message\r\n    return {\"result\": result, \"message\": message, \"cst_date\": cst_date, \"errorType\": errorType,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - result
    - message
    - key
    - keyType
    - valueType
    - value
    - errorType
    - errorProvider
  results:
    - SUCCESS: '${result == "True"}'
      CUSTOM_0: '${result == "name"}'
    - FAILURE
