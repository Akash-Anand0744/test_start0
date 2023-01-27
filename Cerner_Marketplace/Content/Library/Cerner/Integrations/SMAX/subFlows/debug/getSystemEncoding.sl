namespace: Cerner.Integrations.SMAX.subFlows.debug
operation:
  name: getSystemEncoding
  python_action:
    use_jython: false
    script: |-
      # do not remove the execute function
      import os, sys, locale
      def execute():
          return {"out":os.getenv("PYTHONUTF8"),"sysenc":sys.getfilesystemencoding(),"localenc":locale.getpreferredencoding()}
      # you can add additional helper methods below.
  outputs:
    - out
    - sysenc
    - localenc
  results:
    - SUCCESS
