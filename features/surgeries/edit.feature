Feature: Editing surgery
  User should be able to edit surgery information

  @javascript
  Scenario: User editing an abstraction with indirect sources
    Given abstraction schemas are set
    And surgical procedures with the following information exist
      | Surgery Case ID | Description                  | Modifier |
      |      100        | Left temporal lobe resection | Left     |
      |      100        | Insert shunt                 | Left     |
    And surgeries with the following information exist
      | Surgery Case ID | Surgery Case Number | Patient ID |
      |      100        | OR-123              |     1      |
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             |
      | Hello, you look suspicious.         |      1     | 2/1/2014 |  456             |
      | Hello, you look better than before. |      2     | 5/1/2014 |  789             |
    And surgical procedure reports with the following information exist
      | Note Text                           | Patient ID | Date      | Reference Number |
      | Surgery went well.                  |      1     | 1/1/2013  | 111              |
      | Surgery went not so well.           |      1     | 2/1/2013  | 222              |
      | Hello, you look better than before. |      2     | 5/1/2013  | 333              |
    When I go to the last surgery edit page
    And I click on ".edit_link" within the last ".abstractor_abstraction"
    And I wait for the ajax request to finish
    And I select "123 (2014-01-01)" from ".indirect_source_list" in the first ".indirect_source"
    And I wait for the ajax request to finish
    Then ".indirect_source_text" in the first ".indirect_source" should contain text "Hello, you look good to me."
    When I fill in "input.combobox" autocompleter within the first ".has_imaging_confirmed_extent_of_resection" with "Gross total resection"
    When I press "Save"
    And I go to the last surgery edit page
    And I click on ".edit_link" within the last ".abstractor_abstraction"
    And I wait for the ajax request to finish
    Then ".indirect_source_list" in the first ".indirect_source" should have "123 (2014-01-01)" selected
    When I go to the last surgery edit page
    When I confirm link "Add Surgery Anatomical Location"
    And I wait for the ajax request to finish
    And I click on ".edit_link" within the last ".abstractor_abstraction"
    And I select "456 (2014-01-02)" from ".indirect_source_list" in the first ".indirect_source"
    And I wait for the ajax request to finish
    Then ".indirect_source_text" in the first ".indirect_source" should contain text "Hello, you look suspicious."
    When I fill in "input.combobox" autocompleter within the last ".has_imaging_confirmed_extent_of_resection" with "Gross total resection"
    When I press "Save"
    And I go to the last surgery edit page
    And I click on ".edit_link" within the last ".abstractor_abstraction"
    Then ".indirect_source_list" in the first ".indirect_source" should have "456 (2014-01-02)" selected

  @javascript
  @wip
  Scenario: User editing an abstraction with a suggestion against a complex source
    Given abstraction schemas are set
    And surgical procedures with the following information exist
      | Surgery Case ID | Description                  | Modifier |
      |      100        | Left temporal lobe resection | Left     |
      |      100        | Insert shunt                 | Left     |
    And surgeries with the following information exist
      | Surgery Case ID | Surgery Case Number | Patient ID |
      |      100        | OR-123              |     1      |
    And imaging exams with the following information exist
      | Note Text                           | Patient ID | Date     | Accession Number |
      | Hello, you look good to me.         |      1     | 1/1/2014 |  123             |
      | Hello, you look suspicious.         |      1     | 2/1/2014 |  456             |
      | Hello, you look better than before. |      2     | 5/1/2014 |  789             |
    And surgical procedure reports with the following information exist
      | Note Text                           | Patient ID | Date      | Reference Number |
      | Surgery went well.                  |      1     | 1/1/2013  | 111              |
      | Surgery went not so well.           |      1     | 2/1/2013  | 222              |
      | Hello, you look better than before. |      2     | 5/1/2013  | 333              |
    When I go to the last surgery edit page
    And I click on "span.abstractor_abstraction_source_tooltip_img" within the first ".edit_abstractor_abstraction"
    Then I should see an ".highlight" element
    And ".abstractor_source_tab label" should contain text "Surgical Procedure: Description"
    And ".abstractor_source_tab_content" should contain text "Left temporal lobe resection"
    And ".abstractor_source_tab_content" should equal highlighted text "temporal lobe"
    When I go to the last surgery edit page
    And I click on ".edit_link" within the last ".abstractor_abstraction"
    And I wait 30 seconds
    Then I should see 4 "span.abstractor_abstraction_source_tooltip_img" within the last ".edit_abstractor_abstraction"