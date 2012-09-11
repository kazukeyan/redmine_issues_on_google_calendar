module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's Projects dynamically.  Adds a +after_save+ filter.
  module EnabledModulePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        after_create :save_google_calendar, :if => Proc.new { |enabled_module| enabled_module.name == "redmine_issues_on_google_calendar" }
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def save_google_calendar
        self.project.save_google_calendar
      end
    end
  end
end