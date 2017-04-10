Feature: Listing and searching abstractor object values
  User should be able to list and search for abstractor object values

  @javascript
  Scenario: Viewing and searching a list of abstractor object values
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code |
      | abdomen, nos                                                        |      C76.2      |
      | connective, subcutaneous and other soft tissues of abdomen          |      C49.4      |
      | peripheral nerves and autonomic nervous system of abdomen           |      C47.4      |

  @javascript
  Scenario: Deleting an abstractor object value
    Given abstraction schemas are set
    When I go to the abstraction schemas index page
    And I follow "Values" within the "Anatomical location" schema
    Then I should see the first 10 "Anatomical location" abstractor object values
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code |
      | abdomen, nos                                                        |      C76.2      |
      | connective, subcutaneous and other soft tissues of abdomen          |      C49.4      |
      | peripheral nerves and autonomic nervous system of abdomen           |      C47.4      |
    When I follow "Delete" within the first ".abstractor_object_value" and accept confirm
    When I fill in "Search" with "abdomen"
    And I press "Search"
    Then I should see the following "Anatomical location" abstractor object values
      | Value                                                               | Vocabulary Code |
      | connective, subcutaneous and other soft tissues of abdomen          |      C49.4      |
      | peripheral nerves and autonomic nervous system of abdomen           |      C47.4      |
