require 'rack'
require 'filewatcher'

# An automatic reloading Rack development web server for Ruby.
class MachineGun
  
  # Helper method to instantiate a new object and run the server.
  # @see #run
  def self.run *args
    new.run *args
  end
  
  def initialize
    @running = false
  end
  
  # Run the automatically-reloading web server.
  # This method blocks.
  # @option opts [Numeric] :interval (0.5) Interval in seconds to scan the
  #   filesystem for changes.
  def run opts = {}
    @running = true
    interval = opts[:interval] || 0.5
     
    @pid = start_server
     
    @watcher = FileWatcher.new("./**/*.rb")
    
    @watcher.watch interval do
      stop_server
      @pid = start_server
    end
  end
  
  # Stop watching for file changes and shutdown the web server.
  def stop
    return unless @running
    
    @watcher.stop
    stop_server
    @running = false
  end
  
  # @return true if the server is running.
  def running?
    @running
  end
  
  private
  
  # Start the web server in a forked process.
  # @return process id
  def start_server
    fork do
      $0 = "rack"
      Rack::Server.start
    end
  end
  
  # Gracefully stop the web server's forked process.
  def stop_server
    Process.kill "INT", @pid
    Process.wait @pid
  end
  
end
