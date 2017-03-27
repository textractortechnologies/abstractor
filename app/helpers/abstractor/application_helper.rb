module Abstractor
  module ApplicationHelper
    def validation_errors?(object, field_name)
      object.errors.messages[field_name].any?
    end

    def format_validation_errors(object, field_name)
      if object.errors.any?
        if !object.errors.messages[field_name].blank?
          object.errors.messages[field_name].join(", ")
        end
      end
    end
  end
end
