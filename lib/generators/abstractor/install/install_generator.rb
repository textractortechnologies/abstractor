# encoding: UTF-8
require "rails/generators"

module Abstractor
  class InstallGenerator < Rails::Generators::Base
    class_option "no-migrations", :type => :boolean
    class_option "customize-all", :type => :boolean
    class_option "customize-controllers", :type => :boolean
    class_option "customize-models", :type => :boolean
    class_option "customize-helpers", :type => :boolean
    class_option "customize-layout", :type => :boolean
    class_option "current-user-helper", :type => :string
    class_option "no-install-stanford-core-nlp", :type => :boolean

    def self.source_paths
      paths = self.superclass.source_paths
      paths << File.expand_path("../templates", __FILE__)
      paths.flatten
    end

    desc "Used to install Abstractor"

    def install_migrations
      unless options["no-migrations"]
        puts "Copying over Abstractor migrations..."
        Dir.chdir(Rails.root) do
          `rake abstractor:install:migrations`
        end
      end
    end

    ## shameless steal from forem git://github.com/radar/forem.git
    def add_abstractor_application_controller
      current_user_helper = options["current-user-helper"].presence ||
                            ask("What is the current_user helper called in your app? [current_user]").presence ||
                            'current_user if defined?(current_user)'
      puts "Defining abstractor_user method inside ApplicationController..."

      abstractor_user_method = %Q{
  def abstractor_user
    #{current_user_helper}
  end
  helper_method :abstractor_user

  def discard_redirect_to(params, about)
    :back
  end

  def undiscard_redirect_to(params, about)
    :back
  end

  def update_workflow_status_redirect_to(params, about)
    :back
  end
}
      inject_into_file("#{Rails.root}/app/controllers/application_controller.rb",
                       abstractor_user_method,
                       :after => "ActionController::Base\n")
    end

    def add_abstractor_view_helpers
      puts "Defining abstractor view helpers inside ApplicationHelper..."

      abstractor_helper_methods = %Q{
  def show_abstractor_group_all_links?
    true
  end

  def show_abstractor_all_links?
    true
  end

  def show_abstractor_headers?
    false
  end

  def show_abstractor_history?
    false
  end

  def show_abstractor_edit_other_values?
    false
  end

  def show_abstractor_group_workflow_status_links?
    true
  end
}
      inject_into_file("#{Rails.root}/app/helpers/application_helper.rb",
                       abstractor_helper_methods,
                       after: "ApplicationHelper\n")
    end

    def mount_engine
      puts "Mounting Abstractor::Engine at \"/\" in config/routes.rb..."
      insert_into_file("#{Rails.root}/config/routes.rb", :after => /routes.draw.do\n/) do
        %Q{  mount Abstractor::Engine, :at => "/"\n}
      end
    end

    def setup_stanford_core_nlp
      unless options["no-install-stanford-core-nlp"]
        puts "Running rake abstractor:setup:stanford_core_nlp"
        puts 'Please be patient...this could take a while.'
        `rake abstractor:setup:stanford_core_nlp`

        insert_into_file("#{Rails.root}/config/environments/development.rb", :after => /(::Application.configure do\n|application.configure do\n)/) do
'  StanfordCoreNLP.use :english
  StanfordCoreNLP.model_files = {}
  StanfordCoreNLP.jar_path = "#{Rails.root}/lib/stanford-corenlp-full-2015-04-20/"
  StanfordCoreNLP.model_path = "#{Rails.root}/lib/stanford-corenlp-full-2015-04-20/"
  StanfordCoreNLP.default_jars = [
    "joda-time.jar",
    "xom.jar",
    "stanford-corenlp-3.5.2.jar",
    "stanford-corenlp-3.5.2-models.jar",
    "jollyday.jar",
    "bridge.jar"
  ]
'
        end
      end
    end

    def make_customizable
      if options["customize-all"] || options["customize-controllers"]
        path = "#{Rails.root}/app/controllers/abstractor"
        empty_directory path
        copy_file "controllers/abstractor_abstraction_groups_controller.rb", "#{path}/abstractor_abstraction_groups_controller.rb"
        copy_file "controllers/abstractor_abstractions_controller.rb", "#{path}/abstractor_abstractions_controller.rb"
        copy_file "controllers/abstractor_suggestions_controller.rb", "#{path}/abstractor_suggestions_controller.rb"
        copy_file "controllers/abstractor_abstraction_schemas_controller.rb", "#{path}/abstractor_abstraction_schemas_controller.rb"
      end

      if options["customize-all"] || options["customize-helpers"]
        path = "#{Rails.root}/app"
        empty_directory "#{path}/helpers/abstractor"
        copy_file "helpers/abscractions_helper.rb", "#{path}/helpers/abstractor/abscractions_helper.rb"
      end

      if options["customize-all"] || options["customize-models"]
        path = "#{Rails.root}/app"
        empty_directory "#{path}/models/abstractor"
        copy_file "models/abstractor_abstraction_group_member.rb", "#{path}/models/abstractor/abstractor_abstraction_group_member.rb"
        copy_file "models/abstractor_abstraction_group.rb", "#{path}/models/abstractor/abstractor_abstraction_group.rb"
        copy_file "models/abstractor_abstraction_schema_object_value.rb", "#{path}/models/abstractor/abstractor_abstraction_schema_object_value.rb"
        copy_file "models/abstractor_abstraction_schema_predicate_variant.rb", "#{path}/models/abstractor/abstractor_abstraction_schema_predicate_variant.rb"
        copy_file "models/abstractor_abstraction_schema_relation.rb", "#{path}/models/abstractor/abstractor_abstraction_schema_relation.rb"
        copy_file "models/abstractor_abstraction_schema.rb", "#{path}/models/abstractor/abstractor_abstraction_schema.rb"
        copy_file "models/abstractor_abstraction_source.rb", "#{path}/models/abstractor/abstractor_abstraction_source.rb"
        copy_file "models/abstractor_abstraction.rb", "#{path}/models/abstractor/abstractor_abstraction.rb"
        copy_file "models/abstractor_object_type.rb", "#{path}/models/abstractor/abstractor_object_type.rb"
        copy_file "models/abstractor_object_value_variant.rb", "#{path}/models/abstractor/abstractor_object_value_variant.rb"
        copy_file "models/abstractor_object_value.rb", "#{path}/models/abstractor/abstractor_object_value.rb"
        copy_file "models/abstractor_relation_type.rb", "#{path}/models/abstractor/abstractor_relation_type.rb"
        copy_file "models/abstractor_rule_type.rb", "#{path}/models/abstractor/abstractor_rule_type.rb"
        copy_file "models/abstractor_subject_group_member.rb", "#{path}/models/abstractor/abstractor_subject_group_member.rb"
        copy_file "models/abstractor_subject_group.rb", "#{path}/models/abstractor/abstractor_subject_group.rb"
        copy_file "models/abstractor_subject_relation.rb", "#{path}/models/abstractor/abstractor_subject_relation.rb"
        copy_file "models/abstractor_subject.rb", "#{path}/models/abstractor/abstractor_subject.rb"
        copy_file "models/abstractor_suggestion_object_value.rb", "#{path}/models/abstractor/abstractor_suggestion_object_value.rb"
        copy_file "models/abstractor_suggestion_source.rb", "#{path}/models/abstractor/abstractor_suggestion_source.rb"
        copy_file "models/abstractor_suggestion_status.rb", "#{path}/models/abstractor/abstractor_suggestion_status.rb"
        copy_file "models/abstractor_suggestion_status.rb", "#{path}/models/abstractor/abstractor_suggestion.rb"
      end
    end
  end
end