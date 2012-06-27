module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's Issues dynamically.
  module IssuePatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        has_one :event,  :class_name => 'IssueEvent', :foreign_key => 'issue_id'
        after_save :save_google_calendar_event
        after_destroy :delete_google_calendar_event
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def save_google_calendar_event
        unless self.event
          create_google_calendar_event
        else
          update_google_calendar_event
        end
      end

      def create_google_calendar_event
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute({
          :api_method => service.events.insert,
          :parameters => {'calendarId' => self.project.calendar.calendar_id},
          :body => JSON.dump(convert_issue_attributes_for_event),
          :headers => {'Content-Type' => 'application/json'}
        })
        self.create_event({:issue_id => self.id, :event_id => result.data.id})
      end
      
      def update_google_calendar_event
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute({
          :api_method => service.events.update,
          :parameters => {
            'calendarId' => self.project.calendar.calendar_id,
            'eventId' => self.event.event_id
          },
          :body => JSON.dump(convert_issue_attributes_for_event),
          :headers => {'Content-Type' => 'application/json'}
        })
      end
      
      def delete_google_calendar_event
        service = $google_api_client.discovered_api('calendar', 'v3')
        result = $google_api_client.execute({
          :api_method => service.events.delete,
          :parameters => {
            'calendarId' => self.project.calendar.calendar_id,
            'eventId' => self.event.event_id
          },
          :headers => {'Content-Type' => 'application/json'}
        })
        self.event.destroy
      end
      
      def convert_issue_attributes_for_event
        event = {
          'summary' => self.subject,
          'start' => {
            'date' => self.start_date.to_s
          },
          'end' => {
            'date' => self.due_date.to_s
          },
          'attendees' => [
            {
              'email' => self.assigned_to.mail
            }
          ]
        }
      end
    end
  end
end