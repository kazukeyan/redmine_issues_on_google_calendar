module RedmineIssuesOnGoogleCalendar
  # Patches Redmine's ProjectsController dynamically.
  module ProjectsControllerPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        alias_method_chain :create, :hook
        alias_method_chain :update, :hook
      end

    end
    
    module ClassMethods
      # class_methods
    end
    
    module InstanceMethods
      # instance_methods
      def create_with_hook
        @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
        @trackers = Tracker.all
        @project = Project.new
        @project.safe_attributes = params[:project]

        if validate_parent_id && @project.save
          @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
          # Add current user as a project member if he is not admin
          unless User.current.admin?
            r = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
            m = Member.new(:user => User.current, :roles => [r])
            @project.members << m
          end
          call_hook(:controller_projects_new_after_save, { :params => params, :project => @project})
          respond_to do |format|
            format.html { 
              flash[:notice] = l(:notice_successful_create)
              redirect_to :controller => 'projects', :action => 'settings', :id => @project
            }
            format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
          end
        else
          respond_to do |format|
            format.html { render :action => 'new' }
            format.api  { render_validation_errors(@project) }
          end
        end
      end
      
      def update_with_hook
        @project.safe_attributes = params[:project]
        if validate_parent_id && @project.save
          @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
          call_hook(:controller_projects_update_after_save, { :params => params, :project => @project})
          respond_to do |format|
            format.html { 
              flash[:notice] = l(:notice_successful_update)
              redirect_to :action => 'settings', :id => @project
            }
            format.api  { head :ok }
          end
        else
          respond_to do |format|
            format.html { 
              settings
              render :action => 'settings'
            }
            format.api  { render_validation_errors(@project) }
          end
        end
      end
    end
  end
end