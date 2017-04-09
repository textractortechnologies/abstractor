module Abstractor
  module Methods
    module Models
      module AbstractorObjectValueVariant
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :belongs_to, :abstractor_object_value
          base.send :has_many, :abstractor_suggestion_object_value_variants
          base.send :has_many, :abstractor_suggestions, through: :abstractor_suggestion_object_value_variants

          # Validations
          base.send :validates_presence_of, :value

          # Hooks
          base.send :after_create,    :update_abstractor_object_value
          base.send :after_update,    :update_abstractor_object_value
          base.send :after_destroy,   :update_abstractor_object_value
          base.send :after_touch,     :update_abstractor_object_value

          def update_abstractor_object_value
            abstractor_object_value.touch if abstractor_object_value && abstractor_object_value.persisted?
          end
        end
      end
    end
  end
end
