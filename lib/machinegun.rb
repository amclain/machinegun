require 'rack'
require 'filewatcher'

# An automatic reloading Rack development web server for Ruby.
class MachineGun
  
  # Run the automatically-reloading web server.
  # This method blocks.
  # @option opts [Numeric] :interval (0.5) Interval in seconds to scan the
  #   filesystem for changes.
  def self.run opts = {}
    interval = opts[:interval] || 0.5
     
    pid = start_server
     
    FileWatcher.new("./**/*.rb").watch(interval) do
      Process.kill "INT", pid
      Process.wait pid
      
      pid = start_server
    end
  end
  
  private
  
  # Start the web server in a forked process.
  # @return process id
  def self.start_server
    pid = fork do
      $0 = "rack"
      Rack::Server.start
    end
    
    pid
  end
  
end
