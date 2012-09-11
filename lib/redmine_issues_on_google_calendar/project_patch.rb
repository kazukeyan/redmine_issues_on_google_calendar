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
        after_save :save_google_calendar, :if => Proc.new { |project| project.module_enabled?("redmine_issues_on_google_calendar") }
        after_destroy :delete_google_calendar, :if => Proc.new { |project| project.module_enabled?("redmine_issues_on_google_calendar") }
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def save_google_calendar
        unless self.calendar
          create_google_calendar
        else
          update_google_calendar
        end
      end
      
      def create_google_calendar
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute(
          :api_method => service.calendars.insert,
          :body => JSON.dump(convert_project_attributes_for_calendar),
          :headers => {'Content-Type' => 'application/json'}
        )
        self.create_calendar({:project_id => self.id, :calendar_id => result.data.id})
      end
      
      def update_google_calendar
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute(
          :api_method => service.calendars.update,
          :parameters => {'calendarId' => self.calendar.calendar_id},
          :body => JSON.dump(convert_project_attributes_for_calendar),
          :headers => {'Content-Type' => 'application/json'}
        )
      end
            
      def delete_google_calendar
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute({
          :api_method => service.calendars.delete,
          :parameters => {'calendarId' => self.calendar.calendar_id},
          :headers => {'Content-Type' => 'application/json'}
        })
        self.calendar.destroy
      end

      def convert_project_attributes_for_calendar
        calendar = {
          :summary => self.name,
          :description => self.description
          }
        if self.calendar
          if self.calendar.timezone.present?
            calendar[:timeZone] = self.calendar.timezone
          end
        end
        calendar
      end
    end
  end
end