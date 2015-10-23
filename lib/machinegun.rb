require 'rack'
require 'filewatcher'

class MachineGun

  def self.run(interval = nil)
    pid = start_server

    FileWatcher.new("./**/*.rb").watch(interval || 0.5) do
      Process.kill "INT", pid
      Process.wait pid

      pid = start_server
    end
  end

  private

  def self.start_server
    pid = fork do
      $0 = "rack"
      Rack::Server.start
    end

    pid
  end

end
