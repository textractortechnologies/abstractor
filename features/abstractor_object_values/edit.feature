Feature: Editing an abstractor object value
  User should be able to edit an abstractor object value

  @javascript
  Scenario: Prevent editing an abstractor object value with suggestions
    Given abstraction schemas are set
    And radiation therapy prescriptions with the following information exist
      | Site                                    |
      | abdomen, nos                            |
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code |
      | abdomen, nos                                                        | abdomen, nos                                                |
      | connective, subcutaneous and other soft tissues of abdomen          | connective, subcutaneous and other soft tissues of abdomen  |
      | peripheral nerves and autonomic nervous system of abdomen           | peripheral nerves and autonomic nervous system of abdomen   |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then the "Value" field should be disabled and contain the value "abdomen, nos"
    And the "Vocabulary Code" field should be disabled and contain the value "abdomen, nos"
    And the "Comments" field should not be disabled and contain the value ""
    And "Case Sensitive?" in the first ".case_sensitive" should not be checked and should be disabled

  @javascript
  Scenario: Allowing edit of an abstractor object value without suggestions
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code |
      | abdomen, nos                                                        | abdomen, nos                                                |
      | connective, subcutaneous and other soft tissues of abdomen          | connective, subcutaneous and other soft tissues of abdomen  |
      | peripheral nerves and autonomic nervous system of abdomen           | peripheral nerves and autonomic nervous system of abdomen   |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then the "Value" field should not be disabled and contain the value "abdomen, nos"
    And the "Vocabulary Code" field should not be disabled and contain the value "abdomen, nos"
    And the "Comments" field should not be disabled and contain the value ""
    And "#abstractor_object_value_case_sensitive" should not be checked
    Then I should see the following variants
      | Value                                                               | Case Sensitve? |
      | abdominal wall, nos                                                 | no             |
      | intra-abdominal site, nos                                           | no             |
    And I fill in "Value" with "abdomen, nos moomin"
    And I fill in "Vocabulary Code" with "abdomen, nos little my"
    And I fill in "Comments" with "hello moomin"
    And I check "Case Sensitive?" within the first ".case_sensitive"
    And I check "Case Sensitive?" within the last ".abstractor_object_value_variant"
    And I press "Save"
    When I fill in "Search" with "abdomen, nos moomin"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code         |
      | abdomen, nos moomin                                                 |  abdomen, nos little my |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then the "Value" field should not be disabled and contain the value "abdomen, nos moomin"
    And the "Vocabulary Code" field should not be disabled and contain the value "abdomen, nos little my"
    And the "Comments" field should not be disabled and contain the value "hello moomin"
    And "#abstractor_object_value_case_sensitive" should be checked
    When I follow "Delete" within the first ".abstractor_object_value_variant" and accept confirm
    And I press "Save"
    When I fill in "Search" with "abdomen, nos moomin"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code         |
      | abdomen, nos moomin                                                 |  abdomen, nos little my |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then I should see the following variants
      | Value                                                               | Case Sensitve? |
      | intra-abdominal site, nos                                           | yes            |
    When I fill in "Variant Value" with "moomin"
    And I uncheck "Case Sensitive?" within the first ".abstractor_object_value_variant"
    And I press "Save"
    When I fill in "Search" with "abdomen, nos moomin"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code         |
      | abdomen, nos moomin                                                 |  abdomen, nos little my |
    When I follow "Edit" within the first ".abstractor_object_value"
    Then I should see the following variants
      | Value   | Case Sensitve? |
      | moomin  | no             |