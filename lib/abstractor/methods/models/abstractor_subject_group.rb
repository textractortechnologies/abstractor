module Abstractor
  module Methods
    module Models
      module AbstractorSubjectGroup
        def self.included(base)
          base.send :include, SoftDelete

          # Associations
          base.send :has_many, :abstractor_subject_group_members
          base.send :has_many, :abstractor_subjects, :through => :abstractor_subject_group_members
          base.send :has_many, :abstractor_abstraction_groups
          base.send :has_many, :abstractor_abstractions, :through => :abstractor_abstraction_groups

          # base.send :attr_accessible, :deleted_at, :name
        end
      end
    end
  end
end
