module Abstractor
  module Enum
    ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN = 'unknown'
    ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE = 'not applicable'
    ABSTRACTION_OTHER_VALUE_TYPES = [ABSTRACTION_OTHER_VALUE_TYPE_UNKNOWN, ABSTRACTION_OTHER_VALUE_TYPE_NOT_APPLICABLE]

    ABSTRACTION_STATUS_NEEDS_REVIEW = 'needs review'
    ABSTRACTION_STATUS_REVIEWED = 'reviewed'
    ABSTRACTION_STATUS_ACTUALLY_ANSWERED = 'actually answered'
    ABSTRACTION_STATUSES = [ABSTRACTION_STATUS_NEEDS_REVIEW, ABSTRACTION_STATUS_REVIEWED, ABSTRACTION_STATUS_ACTUALLY_ANSWERED]

    ABSTRACTION_SUGGESTION_TYPE_UNKNOWN = 'unknown'
    ABSTRACTION_SUGGESTION_TYPE_SUGGESTED = 'suggested'
    ABSTRACTION_SUGGESTION_TYPES = [ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, ABSTRACTION_SUGGESTION_TYPE_SUGGESTED]

    ABSTRACTOR_SECTION_TYPE_CUSTOM = 'custom'
    ABSTRACTOR_SECTION_TYPE_NAME_VALUE = 'name/value'
    ABSTRACTOR_SECTION_TYPES = [ABSTRACTOR_SECTION_TYPE_CUSTOM, ABSTRACTOR_SECTION_TYPE_NAME_VALUE]

    ABSTRACTOR_GROUP_SENTINENTAL_SUBTYPE = 'sentinental'
  end
end