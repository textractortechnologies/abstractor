module Abstractor
  module Methods
    module Models
      module AbstractorRuleAbstractorSubject
        def self.included(base)
          base.send :include, SoftDelete
          base.send :has_paper_trail

          # Associations
          base.send :belongs_to, :abstractor_rule,    inverse_of: :abstractor_rule_abstractor_subjects
          base.send :belongs_to, :abstractor_subject

          base.send :validates_associated, :abstractor_rule
          base.send :validates_associated, :abstractor_subject
          base.send :validates_uniqueness_of, :abstractor_rule, scope: [:abstractor_subject, :deleted_at]
        end
      end
    end
  end
end
