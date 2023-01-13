########################################################################################################################
#!!
#! @input error_code: Code of the Error
#! @input error_message: Standard description of Error
#! @input error_provider: error provider like Jira, GIT,WIKI, SMAX etc. Error generated while executing action against the provider
#! @input error_log_file: Log file name where error will be logged. If file does not exist then it will be created
#! @input error_level: Level of Error DEBUG, INFO, WARNING, ERROR, CRITICAL
#! @input error_log_file_folder: Optional:  folder name where log file is located
#! @input base_log_folder: Optional: Base Log Folder where all SMAX/HCMx Logs are written
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Operations
operation:
  name: DF_Error_logger
  inputs:
    - error_code
    - error_message
    - error_provider
    - error_log_file
    - error_level
    - error_log_file_folder:
        required: false
        default: ''
    - base_log_folder
    - flow_run_id
  python_action:
    use_jython: false
    script: "###############################################################\n#   OO operation for Writing Logs in logfile for Error Logger\n#   Author: Rakesh Sharma (rakesh.sharma@cerner.com)\n#   Inputs:\n#       -  base_log_folder\n#       -  error_log_file_folder\n#       -  error_log_file\n#       -  error_code\n#       -  error_message\n#       -  error_provider\n#       -  error_level\n#       -  flow_run_id\n#\n#   Outputs:\n#       - result\n#       - message\n#\n#   Created On: 22 Sep 2021\n#  -------------------------------------------------------------\n#   Modified On\t:\n#   Modified By\t:\n#   Modification:\n#################################################################\n\n# do not remove the execute function\ndef execute(base_log_folder,error_log_file_folder, error_log_file, error_code,error_message,error_provider,error_level,flow_run_id):\n    message = \"\"\n    result = \"True\"\n   \n    try:\n        \n        import os\n\n        # Get Folder status if exists else raise Exception\n        if not os.access(base_log_folder, os.W_OK):\n            msg = 'Cannot write to Folder {}'.format(base_log_folder)\n            raise Exception(msg)\n\n        # check if Use requested log folder exists\n        logfolderpath = os.path.join(base_log_folder,error_log_file_folder)\n        if not os.path.exists(logfolderpath):\n            # create the request log folder\n            os.mkdir(logfolderpath)\n\n        # create complete file path for the erro log file\n        cfpath = os.path.join(base_log_folder, error_log_file_folder, error_log_file)\n        \n        # import dateime to read the current timestamp\n        from datetime import datetime\n        \n        # get current time and timezone as UTC\n        ts = datetime.utcnow().isoformat()\n        tz = 'UTC'\n\n        # Create the Error Logging Format for loggin in error file\n        log_format = \"{} {} {} {} {}:OO FlowID-{}: {}\\n\".format(ts, tz, error_provider, error_code, error_level, flow_run_id,error_message)\n\n        #  creating/opening a file to write the error logs\n        f = open(cfpath, \"a\")\n\n        # writing  error logs in the file\n        f.write(str(log_format))\n\n        # closing the  error log file\n        f.close()\n        message = 'Successfully Logged Error in Logfile {}'.format(error_log_file)\n\n    except Exception as e:\n        message = e\n        result = \"False\"\n\n    return {\"result\": result, \"message\": message}\n# you can add additional helper methods below."
  outputs:
    - message
    - result
  results:
    - SUCCESS: '${result=="True"}'
    - FAILURE
