namespace: Cerner.DigitalFactory.Error_Notification.Test
flow:
  name: readLogFile
  inputs:
    - logfileName: /var/log/oo/mpp_eod_oo/mpp_oo_error.logs
  workflow:
    - read_from_file:
        do:
          io.cloudslang.base.filesystem.read_from_file:
            - file_path: '${logfileName}'
        publish:
          - read_text
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      read_from_file:
        x: 148
        'y': 145
        navigate:
          59e1b413-6203-1707-f7f3-b32d7b652298:
            targetId: 8541c333-ad0e-0995-1231-af57baf73d9f
            port: SUCCESS
    results:
      SUCCESS:
        8541c333-ad0e-0995-1231-af57baf73d9f:
          x: 476
          'y': 145
