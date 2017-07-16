Feature: Editing an abstractor rule
  User should be able to see abstractor rules

  @javascript
  Scenario: Allowing edit of an abstractor rule
    Given abstraction schemas are set
    And abstractor rules with the following information exist
      | Name      | Rule        | Abstractor abstraction schema           | Abstractor subject |
      | moomin    | Rule em     | has_anatomical_location, has_laterality | Surgery            |         
      | moomin #1 | Snork rules | has_anatomical_location, has_laterality | Surgery            |         
    When I go to the abstractor rules index page
    When I fill in "Search" with "Snork"
    And I press "Search"
    Then I should see the following abstractor rules
      | Name       | Abstractor Subjects |
      | moomin #1  | PathologyCase       |