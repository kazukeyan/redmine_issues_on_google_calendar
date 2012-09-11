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
        after_save :save_google_calendar_event, :if => Proc.new { |issue| issue.project.module_enabled?("redmine_issues_on_google_calendar") }
        after_destroy :delete_google_calendar_event, :if => Proc.new { |issue| issue.project.module_enabled?("redmine_issues_on_google_calendar") }
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
          if self.project.calendar.delete_after_close && self.closing?
            delete_google_calendar_event
          else
            update_google_calendar_event
          end
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
        if self.project.calendar.display_format
          summary = parse_display_format
        else
          summary = self.subject
        end
        event = {
          'summary' => summary,
          'start' => {
            'date' => self.start_date.to_s
          },
          'end' => {
            # When to insert all day event, set "start.date" and "end.date".
            # But "end.date" is displayed one day before that one inserted by API on calendar
            'date' => (self.due_date ? self.due_date + 1 : '').to_s
          },
          'attendees' => [
            {
              'email' => self.assigned_to.mail
            }
          ]
        }
      end
      
      private
      
      def parse_display_format
        self.project.calendar.display_format.gsub(/[\{].*?[\}]/) do |word|
          attributes = word.gsub(/[\{\}\s]/, '')
          get_recursive_attribute = Proc.new{|obj, attributes|
            attribute = attributes.shift
            # If association defined, "#{attribute}_id" can be called
            begin obj.send "#{attribute}_id".to_sym
              get_recursive_attribute.call(obj.send(attribute.to_sym), attributes)
            rescue
              obj[attribute.to_sym] || attribute
            end
          }
          get_recursive_attribute.call(self, attributes.split("."))
        end
      end
    end
  end
end