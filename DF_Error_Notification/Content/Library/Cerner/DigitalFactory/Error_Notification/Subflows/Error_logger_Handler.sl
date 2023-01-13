########################################################################################################################
#!!
#! @description: Input is simple and explained against each, also there is default value in some of the inputs.
#!                
#!               Output status give the success or failure and Message.
#!                
#!               The error log file is available in the NFS Folder:
#!               <NFS Server>:/var/vols/itom/itsma/global-volume/logs/oo/<tenant ID>/<error_log_file_folder>/<error_log_file>
#!                
#!               Below is location with default values in Dev Instance for Reference purpose
#!                
#!               fs-d5bb77ae.efs.us-east-2.amazonaws.com:/var/vols/itom/itsma/global-volume/logs/oo/336419949/mpp_eod_oo/mpp_oo_error.logs
#!
#! @input error_code: Code of the Error
#! @input error_message: Standard description of Error
#! @input error_provider: error provider like Jira, GIT,WIKI, SMAX etc. Error generated while executing action against the provider
#! @input error_log_file: Log file name where error will be logged. If file does not exist then it will be created
#! @input error_level: Level of Error DEBUG, INFO, WARNING, ERROR, CRITICAL
#! @input error_log_file_folder: Optional:  folder name where log file is located
#! @input base_log_folder: Optional: Base Log Folder where all SMAX/HCMx Logs are written.  This folder must exist. Default is /var/log/oo
#!
#! @output error_logger_status: If Error Logger successfully logged the error in the Log files
#! @output error_logger_message: Error Logger Message
#!
#! @result validation_Issue: If failed for writing to log file
#! @result SUCCESS: Successfully executed
#! @result FAILURE: Any failure that resulted in absolute failure of the flow
#!!#
########################################################################################################################
namespace: Cerner.DigitalFactory.Error_Notification.Subflows
flow:
  name: Error_logger_Handler
  inputs:
    - error_code
    - error_message
    - error_provider
    - error_log_file: mpp_oo_error.logs
    - error_level: ERROR
    - error_log_file_folder:
        default: ''
        required: false
    - base_log_folder:
        default: "${get_sp('Cerner.DigitalFactory.Error_Notification.BASE_LOG_FOLDER')}"
        required: true
  workflow:
    - DF_Error_logger:
        worker_group: RAS_Operator_Path
        do:
          Cerner.DigitalFactory.Error_Notification.Operations.DF_Error_logger:
            - error_code: '${error_code}'
            - error_message: '${error_message}'
            - error_provider: '${error_provider}'
            - error_log_file: '${error_log_file}'
            - error_level: '${error_level}'
            - error_log_file_folder: '${error_log_file_folder}'
            - base_log_folder: '${base_log_folder}'
            - flow_run_id: '${run_id}'
        publish:
          - message
          - result
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: Check_if_log_folder_NOT_writable
    - Check_if_log_folder_NOT_writable:
        do:
          io.cloudslang.base.strings.string_occurrence_counter:
            - string_in_which_to_search: '${message}'
            - string_to_find: Cannot write to Folder
        navigate:
          - SUCCESS: validation_Issue
          - FAILURE: on_failure
  outputs:
    - error_logger_status: '${result}'
    - error_logger_message: '${message}'
  results:
    - validation_Issue
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      DF_Error_logger:
        x: 64
        'y': 96
        navigate:
          b08d87d1-fd41-1a39-628b-ba2e9d0fbd03:
            targetId: 4f8ab854-57ed-6644-1a7f-d4eafedc1d7c
            port: SUCCESS
      Check_if_log_folder_NOT_writable:
        x: 347
        'y': 96
        navigate:
          98fdeec2-68f0-e8bc-b408-30c9923bfe96:
            targetId: a22a43d9-47f4-3438-360b-287f7cf07757
            port: SUCCESS
    results:
      validation_Issue:
        a22a43d9-47f4-3438-360b-287f7cf07757:
          x: 647
          'y': 94
      SUCCESS:
        4f8ab854-57ed-6644-1a7f-d4eafedc1d7c:
          x: 56
          'y': 264
