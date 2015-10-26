require 'machinegun'
require 'timeout'
require 'net/http'

# To skip the integration tests during development, run the test suite with:
#   SKIP_INTEGRATION_TESTS=true bundle exec rake

# If an exception in the test suite is raised while the web server is running,
# it can cause the error: `TCPServer Error: Address already in use - bind(2)`.
# If this happens, run the following command:
#   netstat -ap |grep 9292
# Find the process number of the rack process:
#   2424/rack
# Then kill that process:
#   sudo kill 2424
describe "integration tests" do
  ARGV.clear # Rack::Server doesn't like RSpec's args.
  
  def write_output_file string
    File.open "output.rb", "w" do |f|
      f.puts _ = <<EOS
def output
  "#{string}"
end
EOS
    end
  end
  
  def query_web_server
    Net::HTTP.get URI("http://localhost:9292/")
  end
  
  let(:client) {}
  let(:machinegun) { MachineGun.new }
  let(:machinegun_thread) { Thread.new { machinegun.run interval: interval } }
  
  # FileWatcher blows up if the interval is a string. Pass a string here to
  # make sure the MACHINEGUN_INTERVAL env var is converted correctly.
  let(:interval) { "1" }
  
  let(:message_1) { "message 1" }
  let(:message_2) { "message 2" }
  
  around { |test|
    Dir.chdir("spec/web_app") { test.run }
  }
  
  after {
    Timeout.timeout(10) do
      machinegun.stop
      machinegun_thread.join
    end
  }
  
  specify do
    puts "" # New line for web server to print to stdout.
    write_output_file message_1
    machinegun.running?.should eq false
    
    # Start the web server.
    machinegun_thread
    sleep 1
    
    machinegun.running?.should eq true
    query_web_server.should eq message_1
    sleep 1
    
    # Cause file system changes that should reload the server.
    write_output_file message_2
    sleep interval.to_f + 1
    
    query_web_server.should eq message_2
  end
end unless ENV["SKIP_INTEGRATION_TESTS"]
