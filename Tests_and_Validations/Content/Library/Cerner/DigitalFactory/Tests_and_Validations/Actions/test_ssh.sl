namespace: Cerner.DigitalFactory.Tests_and_Validations.Actions
flow:
  name: test_ssh
  inputs:
    - host: 10.40.34.21
    - sshkey:
        default: |-
          -----BEGIN RSA PRIVATE KEY-----
          MIIEpQIBAAKCAQEAoK7hCfcwadV0pVqTcFg7GWd9Tp76PvvdVU9IQzmDbgnV1EfH
          WPMol7xQHfJ0LcQL5fNjhbHCRatMqsQR2R5JDDP/i/4xEGfpGA5on7KJ/1ljqmh5
          35LFG1UgjMVX47o6wwkv2Yi3IjGWV8zOEfcnve6Wc/HRZGN1BgAmxEz1HDNmPMiz
          zuMXM1Cg9HG2/0bb9Bh9tZvtFust08P7jcS4n4CmncV8isp6rCJGCtpVHBFc45EI
          eod6hnNHcB/xIr0stHEro4ilODz4aH3TxlVn4YMFLEGyZXYS+r9KOCk31uDAn2Wc
          bmxpSUDoZJDIcAOdC/O+FA8Bvj35xo/x7oIJkQIDAQABAoIBAQCNs4tLoY01WAPF
          KsppQbXkompUIkjnsG+xIvjEJ/0q1kuXKDG51L4QigZRUpZ4IbKoeGpk5a1AiV9U
          HRLsWRPsShLrnyAfqrNZ/qLvaqDd6jPFfNs1ehaPExRgcEwgzQOzKe/js/hklDxU
          c42rND389mICH9gb4sW5o/qMFJ333kcVqdFPqC87QRcpqS1CIvbM5AdlmmzO6vED
          CaFm84sr/ZOJMddjengRGbDGjKadE4/V13cixmvIpTEDSFteKcdzpo/IZV5K7cPG
          xjL0wwnkop7Lv5jB4PyZReAt9auujdGv3jzorWdx3ZBKNcCA3rm2gdpaHzMWmHML
          4sNNzAadAoGBAOh2uKYL3qE2IrPK20OEpKfiRsOvZjjdGU8XjPEEZdg5bEnAdNS1
          SAU4szERzhDAhxuJGlkcEE1Uh+irvXgGO5Te0d10mn8HwsGxflIiTCUyxSyq82GN
          RbzrSYB31RUpPi2p8Pozj4Bu+ZX8olUJ5ViGzUZ8g0xxna4L7Ph8MVbLAoGBALDz
          qO6PA3S2G4LnzxK2P6KZKWyOCQJQxjmwimI7kU0FDtmlxKI6tttUhHai/sCGbNpd
          7RWU96ncjiCbSDwNs814AFttdKjdm0kJfgM9/9l0H9mMf1WSskI3HooLEmQHg+UG
          S/RjQhPhDj0oruOzTOTVia7Zdlyb/98inCOQTjmTAoGAVKd3UrCb4GVQedzzwEC7
          nY+faX+kYCzUHKNc5iBN3lH7B1iYsyVZFt2xE7uCKUOTcAmbmLvJi/+uhqKUGvNa
          GzqRfm4KHRx8ZgD3GX338MvuVffjLbE+pi+g0rHQ3SXpyMNMSDEinwjKxz3697Dk
          3joo4vRQ9DOj0k/xegPwC8UCgYEAqwGfBYTyWw1OwxCQ/s1f7BxGeyE8tZ8oIkJp
          Sgu1HRDBTDc2M224n3grV5enyJlggxv4bj37po1+USagBWFcnTnWZoT+E9+uHURu
          ImX9ZsIhsZVkzWcqnHE2M0QF7uOQZHnUV4bBKgL6RsKVWXpC2nc/Stnf2Bnuik6h
          RIFGB78CgYEA2URYZ7sBGB2JzDY0oU4BaFNTM09Qg+NYozAl6JetlCLsEr0agf6c
          bIJby8hVOHoXdDQN1bP+r34vCPBQHPX1cQLRMdPYCH/cg3DjDLJLFhs6etuh6RRo
          cSNj+9T/rW6tdJnKMvOFmiSeYakqxPCA7ur7mv+DvZHBms2uENGefKs=
          -----END RSA PRIVATE KEY-----
        sensitive: true
    - user: ec2-user
  workflow:
    - Do_Nothing:
        do_external:
          ddd79f22-8b1e-4605-88d5-d912bb2da2b9: []
        navigate:
          - success: ssh_flow
    - ssh_flow:
        do:
          io.cloudslang.base.ssh.ssh_flow:
            - host: '${host}'
            - command: pwd;date;uname -a
            - username: '${user}'
            - private_key_data: '${sshkey}'
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
            - private_key_data: '${sshkey}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Do_Nothing:
        x: 186
        'y': 127.55555725097656
      ssh_flow:
        x: 270
        'y': 224.5555419921875
      ssh_command:
        x: 420
        'y': 398
        navigate:
          f4a30fc1-cfea-f055-f157-97de0f22a585:
            targetId: 1169f754-a81b-a4c4-d547-2149d2ecb222
            port: SUCCESS
    results:
      SUCCESS:
        1169f754-a81b-a4c4-d547-2149d2ecb222:
          x: 619
          'y': 229
