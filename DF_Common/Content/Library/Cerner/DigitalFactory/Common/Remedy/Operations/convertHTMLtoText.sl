namespace: Cerner.DigitalFactory.Common.Remedy.Operations
operation:
  name: convertHTMLtoText
  inputs:
    - htmlString:
        required: false
  python_action:
    use_jython: false
    script: "###############################################################\r\n#   OO operation for converting html tag  to Texts\r\n#   Author:Rakesh Sharma\r\n#   Operation: convertHTMLtoText\r\n#   Createdon 23 Sep 2022\r\n#   Inputs:\r\n#       - htmlString\r\n#   Outputs:\r\n#       - result\r\n#       - message\r\n#       - wikiString\r\n#       - errorType\r\n#       - errorSeverity\r\n#       - errorProvider\r\n#       - errorMessage\r\n\r\n###############################################################\r\n\r\nimport sys, os\r\nimport subprocess\r\n\r\n\r\n# function do download external modules to python \"on-the-fly\"\r\ndef install(param):\r\n    message = \"\"\r\n    result = \"\"\r\n    errorSeverity = \"\"\r\n    errorType = \"\"\r\n    errorProvider = \"\"\r\n    errorMessage = \"\"\r\n\r\n    try:\r\n\r\n        pathname = os.path.dirname(sys.argv[0])\r\n        message = os.path.abspath(pathname)\r\n        message = subprocess.call([sys.executable, \"-m\", \"pip\", \"list\"])\r\n        message = subprocess.run([sys.executable, \"-m\", \"pip\", \"install\", param], capture_output=True)\r\n        result = \"True\"\r\n\r\n    except Exception as e:\r\n        message = e\r\n        result = \"False\"\r\n        errorSeverity = \"e30000\"\r\n        errorType = \"ERROR\"\r\n        errorProvider = \"SMAX\"\r\n        errorMessage = message\r\n\r\n    return {\"result\": result, \"message\": message, \"errorType\": errorType, \"errorSeverity\": errorSeverity,\r\n            \"errorProvider\": errorProvider, \"errorMessage\": errorMessage}\r\n\r\n\r\n# requirement external modules\r\n\r\ninstall(\"html2text\")\r\n\r\n\r\n# main function\r\ndef execute(htmlString):\r\n    message = \"\"\r\n    result = \"False\"\r\n    textString = \"\"\r\n    errorType = \"\"\r\n    errorSeverity = \"\"\r\n    errorProvider = \"\"\r\n    errorMessage = \"\"\r\n\r\n    try:\r\n        ### https://pypi.org/project/html2text/ -- for html2text\r\n        ### https://github.com/Alir3z4/html2text/blob/master/docs/usage.md\r\n\r\n        import html2text\r\n\r\n        if len(htmlString) > 0:\r\n            ## remove the strong html key and add new line\r\n            htmlString = htmlString.replace(\"\\n\", \"\\\\n\")\r\n            htmlString = htmlString.replace(\"<strong>\",\"\\n\").replace(\"</strong>\",\" \")\r\n\r\n            h = html2text.HTML2Text()\r\n            # Ignore converting links from HTML\r\n            h.ignore_links = True\r\n            h.escape_all = False\r\n            h.single_line_break = False\r\n            h.body_width = 0\r\n            textString = h.handle(htmlString)\r\n            result = \"True\"\r\n\r\n\r\n    except Exception as e:\r\n        message = str(e)\r\n        result = \"False\"\r\n        errorType = \"e10000\"\r\n        errorSeverity = \"ERROR\"\r\n        errorProvider = \"OOExec\"\r\n        errorMessage = message\r\n\r\n    return {\"result\": result, \"message\": message, \"textString\": textString, \"errorType\": errorType,\r\n            \"errorSeverity\": errorSeverity, \"errorProvider\": errorProvider,\r\n            \"errorMessage\": errorMessage}"
  outputs:
    - textString
    - result
    - message
    - errorType
    - errorSeverity
    - errorProvider
    - errorMessage
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
