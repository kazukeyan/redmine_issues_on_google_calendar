module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's Issues dynamically.  Adds a +after_save+ filter.
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_one :event,  :class_name => 'IssueEvent', :foreign_key => 'issue_id'
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def create_google_calendar_event
        service = $google_api_client.discovered_api('calendar', 'v3')
        event = {
          'summary' => self.subject,
          'start' => {
            'date' => self.start_date.to_s
          },
          'end' => {
            'date' => self.due_date.to_s
          }
        }
        result = $google_api_client.execute({
          :api_method => service.events.insert,
          :parameters => {'calendarId' => self.project.calendar.calendar_id},
          :body => JSON.dump(event),
          :headers => {'Content-Type' => 'application/json'}
        })
        self.create_event({:issue_id => self.id, :event_id => result.data.id})
      end
    end
  end
end