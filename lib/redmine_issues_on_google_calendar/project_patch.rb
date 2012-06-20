module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's Projects dynamically.  Adds a +after_save+ filter.
  module ProjectPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_one :calendar,  :class_name => 'ProjectCalendar', :foreign_key => 'project_id'
        after_save :create_google_calendar
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def create_google_calendar
        service = $google_api_client.discovered_api('calendar', 'v3')
        calendar = {:summary => self.name, :description => self.description}
        result = $google_api_client.execute(
          :api_method => service.calendars.insert,
          :body => JSON.dump(calendar),
          :headers => {'Content-Type' => 'application/json'}
        )
        self.create_calendar({:project_id => self.id, :calendar_id => result.data.id})
      end
    end
  end
end