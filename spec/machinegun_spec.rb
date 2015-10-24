require 'machinegun'

describe MachineGun do
  
  # Prevent the test suite process from forking.
  def stub_fork
    allow(MachineGun).to receive(:fork) { |&block|
      block.call
      0 # PID (can't be killed if Process.kill is accidentally called)
    }
  end
  
  # Prevent the rack server from running.
  def stub_rack_server
    Rack::Server.should_receive(:start).at_least(:once)
  end
  
  # Prevent FileWatcher from monitoring the file system.
  def stub_file_watcher
    _interval = (respond_to?(:interval) ? interval : nil) || 0.5
    
    FileWatcher.should_receive(:new).at_least(:once) {
      double().tap do |d|
        d.should_receive(:watch).with(_interval).at_least(:once)
      end
    }
  end
  
  subject { MachineGun }
  
  it { should respond_to :run }
  
  describe "run" do
    before {
      stub_fork
      stub_rack_server
      stub_file_watcher
    }
    
    specify { subject.run }
    
    describe "option: interval" do
      let(:interval) { 2 }
      
      specify { subject.run interval: interval }
      
      # FileWatcher gem default is 0.5 seconds. Follow the gem's recommendation
      # if no interval is provided.
      describe "defaults to 0.5" do
        let(:interval) { nil }
        
        specify { subject.run }
      end
    end
  end
end
