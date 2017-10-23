Feature: Adding an abstractor rule
  User should be able to add an abstractor rule

  @javascript
  Scenario: Adding an abstractor rule
    Given abstraction schemas are set
    When I go to the abstractor rules index page
    And I follow "New"
    And I fill in "Name" with "moomin"
    And I fill in "Description" with "Be a good moomin!"
    And I fill in "Rule" with "moomin code"
    And I select "PathologyCase" from "Abstraction subjects"
    And I press "Save"
    When I fill in "Search" with "moomin"
    And I press "Search"
    Then I should see the following abstractor rules
      | Name    | Abstractor Subjects | Rule        |
      | moomin  | PathologyCase       | moomin code |
    And I follow 'Edit' within the abstractor rule named "moomin"
    And the "Name" field should not be disabled and contain the value "moomin"
    And the "Description" field should not be disabled and contain the value "Be a good moomin!"
    And the "Rule" field should not be disabled and contain the value "moomin code"
    And "PathologyCase" should be selected for "Abstraction subjects"

  @javascript
  Scenario: Adding an abstractor rule value with validation
    Given abstraction schemas are set
    When I go to the abstractor rules index page
    And I follow "New"
    And I press "Save"
    Then "Name" field should display the error message "can't be blank"
    And "Rule" field should display the error message "can't be blank"
    And "Abstraction subjects" field should display the error message "can't be blank"
