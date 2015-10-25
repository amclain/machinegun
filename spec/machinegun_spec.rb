require 'machinegun'

describe MachineGun do
  
  # Prevent the test suite process from forking.
  def stub_fork
    allow(subject).to receive(:fork) { |&block| block.call; pid }
    
    allow(Process).to receive(:kill)
    allow(Process).to receive(:wait)
  end
  
  # Prevent the rack server from running.
  def stub_rack_server opts = {}
    called = opts.fetch :called, :once
    ignore = opts.fetch :ignore, false
    
    if ignore
      allow(Rack::Server).to receive(:start)
    else
      Rack::Server.should_receive(:start).at_least(called)
    end
  end
  
  # Prevent FileWatcher from monitoring the file system.
  def stub_file_watcher opts = {}
    run_block = opts.fetch :run_block, false
    ignore = opts.fetch :ignore, false
    
    _interval = (respond_to?(:interval) ? interval : nil) || 0.5
    
    if ignore
      allow(FileWatcher).to receive(:new) {
        double(FileWatcher).tap do |d|
          allow(d).to receive(:watch)
          allow(d).to receive(:stop)
        end
      }
    else
      FileWatcher.should_receive(:new).at_least(:once) {
        double(FileWatcher).tap do |d|
          allow(d).to receive(:stop)
          
          d.should_receive(:watch).with(_interval).at_least(:once) { |&block|
            block.call if run_block
          }
        end
      }
    end
  end
  
  let(:pid) { 0 } # PID 0 can't be killed if Process.kill is accidentally called.
  
  let(:rack_server_start_called) { :once }
  let(:ignore_rack_server) { false }
  let(:rack_stub_opts) {{
    ignore: ignore_rack_server,
    called: rack_server_start_called,
  }}
  
  let(:ignore_file_watcher) { false }
  let(:run_file_watcher_block) { false }
  let(:file_watcher_opts) {{
    ignore: ignore_file_watcher,
    run_block: run_file_watcher_block,
  }}
  
  before {
    stub_fork
    stub_rack_server rack_stub_opts
    stub_file_watcher file_watcher_opts
  }
  
  describe "class" do
    subject { MachineGun }
    let(:ignore_rack_server) { true }
    let(:ignore_file_watcher) { true }
    
    specify { subject.run }
  end
  
  describe "run" do
    specify { subject.run }
    
    describe "auto-restart" do
      let(:rack_server_start_called) { :twice }
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
  
  describe "running?" do
    let(:ignore_rack_server) { true }
    let(:ignore_file_watcher) { true }
    
    specify "on instantiation" do
      subject.running?.should eq false
    end
    
    specify "after run is called" do
      subject.run
      subject.running?.should eq true
    end
    
    specify "after stop is called" do
      subject.run
      subject.stop
      subject.running?.should eq false
    end
  end
  
  describe "stop" do
    specify "running server" do
      subject.run
      
      Process.should_receive(:kill).with("INT", pid).exactly(:once)
      Process.should_receive(:wait).with(pid).exactly(:once)
      
      subject.stop
    end
    
    describe "stopped server" do
      let(:ignore_rack_server) { true }
      let(:ignore_file_watcher) { true }
      
      specify do
        Process.should_not_receive(:kill).with("INT", pid)
        Process.should_not_receive(:wait).with(pid)
        
        subject.stop
      end
    end
  end
end
