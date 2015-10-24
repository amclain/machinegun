require 'machinegun'

describe MachineGun do
  
  # Prevent the test suite process from forking.
  def stub_fork
    allow(MachineGun).to receive(:fork) { |&block| block.call; pid }
  end
  
  # Prevent the rack server from running.
  def stub_rack_server opts = {}
    called = opts.fetch :called, :once
    Rack::Server.should_receive(:start).at_least(called)
  end
  
  # Prevent FileWatcher from monitoring the file system.
  def stub_file_watcher opts = {}
    run_block = opts.fetch :run_block, false
    _interval = (respond_to?(:interval) ? interval : nil) || 0.5
    
    FileWatcher.should_receive(:new).at_least(:once) {
      double().tap do |d|
        d.should_receive(:watch).with(_interval).at_least(:once) { |&block|
          block.call if run_block
        }
      end
    }
  end
  
  subject { MachineGun }
  
  let(:pid) { 0 } # PID 0 can't be killed if Process.kill is accidentally called.
  let(:rack_server_called) { :once }
  let(:run_file_watcher_block) { false }
  
  it { should respond_to :run }
  
  describe "run" do
    before {
      stub_fork
      stub_rack_server called: rack_server_called
      stub_file_watcher run_block: run_file_watcher_block
    }
    
    specify { subject.run }
    
    describe "auto-restart" do
      let(:rack_server_called) { :twice }
      let(:run_file_watcher_block) { true }
      
      specify do
        Process.should_receive(:kill).with("INT", pid)
        Process.should_receive(:wait).with(pid)
        
        subject.run
      end
    end
    
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
