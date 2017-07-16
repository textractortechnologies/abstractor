Feature: Editing an abstractor rule
  User should be able to edit an abstractor rule

  @javascript
  Scenario: Allowing edit of an abstractor rule
    Given abstraction schemas are set
    And abstractor rules with the following information exist
      | Name   | Rule    | Abstractor abstraction schema           | Abstractor subject |
      | moomin | Rule em | has_anatomical_location, has_laterality | Surgery            |         
    When I go to the abstractor rules index page
    And I follow "Edit"
    And the "Name" field should not be disabled and contain the value "moomin"
    And the "Rule" field should not be disabled and contain the value "Rule em"
    And "Surgery" should be selected for "Abstraction subjects"
    When I fill in "Name" with "moomin #1"
    And I fill in "Rule" with "Snork code"
    And I select "PathologyCase" from "Abstraction subjects"
    And I press "Save"
    When I fill in "Search" with "Snork"
    And I press "Search"
    Then I should see the following abstractor rules
      | Name       | Abstractor Subjects |
      | moomin #1  | PathologyCase       |