require 'drb'

class TracerThing
  
  def run(write_to)
    begin
      require 'rubygems'
      require 'ruby-debug'
      STDOUT.reopen(write_to)
      Debugger.start(:tracing => true)
      return "success"
    rescue => e
      return e.inspect + e.backtrace.join("\n")
    end
  end
  
  def stop
    begin
      Debugger.stop
      STDOUT.reopen(STDERR)
      return "success"
    rescue => e
      return e.inspect + e.backtrace.join("\n")
    end
  end
  
end

class DrbTracer
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    start_drb_if_needed
    @app.call(env)
  end
  
  def start_drb_if_needed
    @drb_thread ||= Thread.new do    
      # start up the DRb service
      DRb.start_service nil, TracerThing.new
      
      # We need the uri of the service to connect a client
      RAILS_DEFAULT_LOGGER.debug("this proc #{Process.pid} can be hooked into at #{DRb.uri}")
    
      # wait for the DRb service to finish before exiting
      DRb.thread.join      
    end
  end
  
end

if defined?(ENABLE_DEBUG_TRACER_HOOK) && ENABLE_DEBUG_TRACER_HOOK
  ActionController::Dispatcher.middleware.use DrbTracer
end
