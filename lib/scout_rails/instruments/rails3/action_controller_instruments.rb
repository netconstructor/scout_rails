# Rails 3
module ScoutRails::Instruments
  module ActionControllerInstruments
    # Instruments the action and tracks errors.
    def process_action(*args)
      scout_controller_action = "Controller/#{controller_path}/#{action_name}"
      self.class.trace(scout_controller_action, :uri => request.fullpath) do
        begin
          super
        rescue Exception => e
          ScoutRails::Agent.instance.store.track!("Errors/Request",1, :scope => nil)
          raise
        ensure
          Thread::current[:scout_scope_name] = nil
        end
      end
    end
  end
end

if defined?(ActionController) && defined?(ActionController::Base)
  ScoutRails::Agent.instance.logger.debug "Instrumenting ActionController::Base"
  ActionController::Base.class_eval do
    include ScoutRails::Tracer
    include ::ScoutRails::Instruments::ActionControllerInstruments
  end
end

if defined?(ActionView) && defined?(ActionView::PartialRenderer)
  ScoutRails::Agent.instance.logger.debug "Instrumenting ActionView::PartialRenderer"
  ActionView::PartialRenderer.class_eval do
    include ScoutRails::Tracer
    instrument_method :render_partial, :metric_name => 'View/#{@template.virtual_path}/Rendering', :scope => true
  end
end
