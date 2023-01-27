namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: test_ssh_1
  inputs:
    - host: 10.190.172.68
    - user: hcmxsvc
    - password:
        default: 'Cerner123!@#'
        sensitive: true
  workflow:
    - ssh_flow:
        do:
          io.cloudslang.base.ssh.ssh_flow:
            - host: '${host}'
            - command: pwd;date;uname -a
            - username: '${user}'
            - password:
                value: '${password}'
                sensitive: true
        publish:
          - return_result
          - standard_out
          - standard_err
          - exception
          - command_return_code
          - return_code
        navigate:
          - SUCCESS: ssh_command
          - FAILURE: on_failure
    - ssh_command:
        do:
          io.cloudslang.base.ssh.ssh_command:
            - host: '${host}'
            - command: pwd;date;uname -a
            - username: '${user}'
            - password:
                value: '${password}'
                sensitive: true
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      ssh_flow:
        x: 360
        'y': 360
      ssh_command:
        x: 680
        'y': 360
        navigate:
          f4a30fc1-cfea-f055-f157-97de0f22a585:
            targetId: 1169f754-a81b-a4c4-d547-2149d2ecb222
            port: SUCCESS
    results:
      SUCCESS:
        1169f754-a81b-a4c4-d547-2149d2ecb222:
          x: 1080
          'y': 360
