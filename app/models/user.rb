class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :token_authenticatable, :registerable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :first_name, :last_name, :password_confirmation, :password, :remember_me
  
  attr_protected :is_admin # don't allow mass-assignment for this
  
  #for will_paginate plugin
  cattr_accessor :per_page
  @@per_page = 5

  has_many :contexts,
           :order => 'position ASC',
           :dependent => :delete_all do
             def find_by_params(params)
               find_by_id(params['id'] || params['context_id']) || nil
             end
             def update_positions(context_ids)
                context_ids.each_with_index {|id, position|
                  context = self.detect { |c| c.id == id.to_i }
                  raise I18n.t('models.user.error_context_not_associated', :context => id, :user => @user.id) if context.nil?
                  context.update_attribute(:position, position + 1)
                }
              end
           end
  has_many :projects,
           :order => 'projects.position ASC',
           :dependent => :delete_all do
              def find_by_params(params)
                find_by_id(params['id'] || params['project_id'])
              end
              def update_positions(project_ids)
                project_ids.each_with_index {|id, position|
                  project = self.detect { |p| p.id == id.to_i }
                  raise I18n.t('models.user.error_project_not_associated', :project => id, :user => @user.id) if project.nil?
                  project.update_attribute(:position, position + 1)
                }
              end
              def projects_in_state_by_position(state)
                self.sort{ |a,b| a.position <=> b.position }.select{ |p| p.state == state }
              end
              def next_from(project)
                self.offset_from(project, 1)
              end
              def previous_from(project)
                self.offset_from(project, -1)
              end
              def offset_from(project, offset)
                projects = self.projects_in_state_by_position(project.state)
                position = projects.index(project)
                return nil if position == 0 && offset < 0
                projects.at( position + offset)
              end
              def cache_note_counts
                project_note_counts = Note.group(:project_id).count
                self.each do |project|
                  project.cached_note_count = project_note_counts[project.id] || 0
                end
              end
              def alphabetize(scope_conditions = {})
                projects = where(scope_conditions)
                projects.sort!{ |x,y| x.name.downcase <=> y.name.downcase }
                self.update_positions(projects.map{ |p| p.id })
                return projects
              end
              def actionize(scope_conditions = {})
                todos_in_project = where(scope_conditions).includes(:todos)
                todos_in_project.sort!{ |x, y| -(x.todos.active.count <=> y.todos.active.count) }
                todos_in_project.reject{ |p| p.todos.active.count > 0 }
                sorted_project_ids = todos_in_project.map {|p| p.id}

                all_project_ids = all.map {|p| p.id}
                other_project_ids = all_project_ids - sorted_project_ids

                update_positions(sorted_project_ids + other_project_ids)

                return where(scope_conditions)
              end
            end
  has_many :todos,
           :order => 'todos.completed_at DESC, todos.created_at DESC',
           :dependent => :delete_all do
              def count_by_group(g)
                except(:order).group(g).count
              end
           end
  has_many :recurring_todos,
           :order => 'recurring_todos.completed_at DESC, recurring_todos.created_at DESC',
           :dependent => :delete_all
  has_many :deferred_todos,
           :class_name => 'Todo',
           :conditions => [ 'state = ?', 'deferred' ],
           :order => 'show_from ASC, todos.created_at DESC' do
              def find_and_activate_ready
                where('show_from <= ?', Time.zone.now).collect { |t| t.activate! }
              end
           end
  has_many :notes, :order => "created_at DESC", :dependent => :delete_all
  has_one :preference, :dependent => :destroy

  validates_presence_of :login
  #validates_presence_of :password, :if => :password_required?
  #validates_length_of :password, :within => 5..40, :if => :password_required?
  #validates_presence_of :password_confirmation, :if => :password_required?
  #validates_confirmation_of :password
  validates_length_of :login, :within => 3..80
  validates_uniqueness_of :login, :on => :create
  #validate :validate_auth_type

  #before_create :crypt_password, :generate_token
  #before_update :crypt_password
  
  after_create :create_preference

  #def validate_auth_type
  #  unless Tracks::Config.auth_schemes.include?(auth_type)
  #    errors.add("auth_type", "not a valid authentication type (#{auth_type})")
  #  end
  #end

  alias_method :prefs, :preference

  def self.no_users_yet?
    count == 0
  end

  def self.find_admin
    where(:is_admin => true).first
  end

  def to_param
    login
  end

  def display_name
    if first_name.blank? && last_name.blank?
      return login
    elsif first_name.blank?
      return last_name
    elsif last_name.blank?
      return first_name
    end
    "#{first_name} #{last_name}"
  end

  def time
    Time.now.in_time_zone(prefs.time_zone)
  end

  def date
    time.midnight
  end

  def at_midnight(date)
    return ActiveSupport::TimeZone[prefs.time_zone].local(date.year, date.month, date.day, 0, 0, 0)
  end
  
  def token
    self.authentication_token
  end

protected
  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(login) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

end
