Feature: Editing an abstractor rule
  User should be able to edit an abstractor rule

  @javascript
  Scenario: Allowing edit of an abstractor rule
    Given abstraction schemas are set
    And abstractor rules with the following information exist
      | Name   | Description                          | Rule             | Abstractor abstraction schema           | Abstractor subject |
      | Moomin | This is the Moomin rule description. | Moomin rule code | has_anatomical_location, has_laterality | Surgery            |
    When I go to the abstractor rules index page
    And I follow "Edit"
    And the "Name" field should not be disabled and contain the value "Moomin"
    And the "Description" field should not be disabled and contain the value "This is the Moomin rule description."
    And the "Rule" field should not be disabled and contain the value "Moomin rule code"
    And "Surgery" should be selected for "Abstraction subjects"
    When I fill in "Name" with "Groke"
    And I fill in "Description" with "This is the Groke rule description."
    And I fill in "Rule" with "Groke rule code"
    And I select "PathologyCase" from "Abstraction subjects"
    And I press "Save"
    When I fill in "Search" with "Groke"
    And I press "Search"
    Then I should see the following abstractor rules
      | Name      | Abstractor Subjects | Rule        |
      | Groke     | PathologyCase       | Groke code  |
    And I follow 'Edit' within the abstractor rule named "Groke"
    Then the "Name" field should contain "Groke"
    And the "Description" field should contain "This is the Groke rule description."
    And the "Rule" field should contain "Groke rule code"
    And "PathologyCase" should be selected for "Abstraction subjects"
