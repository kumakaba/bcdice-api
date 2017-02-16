
@dir = "#{File.dirname(__FILE__)}/"

worker_processes 3
working_directory @dir
preload_app true

timeout 30

pid "/tmp/bcdice-api.unicorn.pid"
stdout_path "/tmp/bcdice-api.unicorn.stdout.log"
stderr_path "/tmp/bcdice-api.unicorn.stderr.log"

