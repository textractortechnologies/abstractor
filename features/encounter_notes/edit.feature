Feature: Editing encounter note
  User should be able to edit encounter note information

  @javascript
  Scenario: Viewing not reviewed suggestions
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "Accepted" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status_date"
    And ".custom_explanation .explanation_text" in the first ".has_karnofsky_performance_status_date" should contain text "A bit of custom logic."

  @javascript
  Scenario: Viewing selected suggestions
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Viewing accepted unknown suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    And I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Viewing unknown suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "unknown"
    And I press "Save"
    And I go to the last encounter note edit page
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Setting an abstraction to unknown for an accepted suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "unknown"
    And I press "Save"
    And I go to the last encounter note edit page
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Setting an abstraction to a non-suggested value for an accepted suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I follow "edit" within ".has_karnofsky_performance_status"
    When I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And I press "Save"
    And I go to the last encounter note edit page
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Setting an abstraction to not applicable for an accepted suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "not applicable"
    And I press "Save"
    And I go to the last encounter note edit page
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Viewing accepted suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      | Looking good. KPS: 100 |
    When I go to the last encounter note edit page
    When I check "Accepted" within ".has_karnofsky_performance_status"
    And I go to the last encounter note edit page
    Then I should see "Karnofsky performance status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Changing status for unknown suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                    |
      | Looking good. Not too sure about KPS though. |
    When I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I uncheck "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for not applicable suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                    |
      | Looking good. Not too sure about KPS though. |
    And I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "not applicable"
    And I press "Save"
    And I go to the last encounter note edit page
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I check "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    When I uncheck "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for a suggestion
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text               |
      | Looking good. KPS: 100. |
    And I go to the last encounter note edit page
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And I go to the last encounter note edit page
    And I check "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"
    And I go to the last encounter note edit page
    And I uncheck "Accepted" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".edit_abstractor_suggestion" in the first ".abstractor_abstraction" should contain selector ".abstractor_abstraction_source_tooltip_img"

  @javascript
  Scenario: Changing status for multiple sugestions
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                                      |
      | Looking good. KPS: 100.  On second thought make that KPS: 50.  |
    When I go to the last encounter note edit page
    And I check "Accepted" within the first ".has_karnofsky_performance_status .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "100% - Normal; no complaints; no evidence of disease."
    And the "Accepted" checkbox within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    When I check "Accepted" within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "50% - Requires considerable assistance and frequent medical care."
    And the "Accepted" checkbox within the first ".has_karnofsky_performance_status .edit_abstractor_suggestion" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    When I uncheck "Accepted" within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "[Not set]"
    And the "Accepted" checkbox within the first ".has_karnofsky_performance_status .edit_abstractor_suggestion" should not be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  Scenario: Viewing source for suggestion with source and match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      |The patient is looking good.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "The patient is looking good.  KPS: 100"
    And ".ui-dialog-content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: Viewing source for suggestion with source containing characters needing to be escaped and match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      |The patient is looking good & fit. Much > than I would have thought.  KPS: 100|
    And I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "The patient is looking good & fit. Much > than I would have thought.  KPS: 100"
    And ".ui-dialog-content" should equal highlighted text "KPS: 100"

  @javascript
  Scenario: Viewing source for suggestion with source and no match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |Hello, your KPS is something. Have a great day!|
    When I go to the last encounter note edit page
    And I click within first ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is something. Have a great day!"
    And ".ui-dialog-content" should equal highlighted text "Hello, your KPS is something."

  @javascript
  Scenario: Viewing source for suggestion with source containing characters needing to be escaped and no match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |The patient is looking good & fit. Much > than I would have thought. The KPS is something. Have a great day!|
    When I go to the last encounter note edit page
    And I click within first ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "The patient is looking good & fit. Much > than I would have thought. The KPS is something. Have a great day!"
    And ".ui-dialog-content" should equal highlighted text "The KPS is something."

  @javascript
  Scenario: Viewing source for unknown suggestion without match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |This is your physical assessment. Have a great day!|
    When I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    And I wait 5 seconds
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "This is your physical assessment. Have a great day!"
    And ".ui-dialog-content" should not equal highlighted text "KPS"

  @javascript
  Scenario: Viewing source for unknown suggestion without match value
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                |
      |The patient is looking good & fit. Much > than I would have thought. Have a great day!|
    When I go to the last encounter note edit page
    And I click within ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    And I wait 5 seconds
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "The patient is looking good & fit. Much > than I would have thought. Have a great day!"
    And ".ui-dialog-content" should not equal highlighted text "KPS"

  @javascript
  Scenario: Viewing source for suggestion with source and multiple match values
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                                                  |
      |Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%!|
    And I go to the last encounter note edit page
    And I click on "i" within the first ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%. Have a great day! Yes, KPS is 100%!"
    And ".ui-dialog-content" should equal highlighted text "Hello, your KPS is 100%."
    And ".ui-dialog-content" should not equal highlighted text "Yes, KPS is 100%!"
    When I go to the last encounter note edit page
    And  I click on "i" within the last ".has_karnofsky_performance_status span.abstractor_abstraction_source_tooltip_img"
    Then I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%. Have a great day!"
    And ".ui-dialog-content" should not equal highlighted text "Hello, your KPS is 100%."
    And ".ui-dialog-content" should equal highlighted text "Yes, KPS is 100%!"

  @javascript
  Scenario: Accessing abstraction edit form
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      |Hello, your KPS is 100%.|
    When I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then the element "select.combobox" should be hidden
    And I should not see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "select.combobox"
    And "select.combobox" in the first ".abstractor_abstraction" should have options "100% - Normal; no complaints; no evidence of disease., 90% - Able to carry on normal activity; minor signs or symptoms of disease., 80% - Normal activity with effort; some signs or symptoms of disease."
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "input#abstractor_abstraction_not_applicable"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And ".abstractor_abstraction_edit" in the first ".abstractor_abstraction" should contain selector "input#abstractor_abstraction_unknown"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    Then ".abstractor_abstraction_edit input[type='submit']" should contain "Save"
    And I should see "Cancel"
    When I check "unknown" within the first ".abstractor_abstraction_edit"
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    When I check "not applicable" within the first ".abstractor_abstraction"
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    When I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    Then "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    And I click on "span.abstractor_abstraction_source_tooltip_img" within the first ".edit_abstractor_abstraction"
    And I should see an ".ui-dialog_abstractor" element
    And ".ui-dialog-titlebar" should contain text "EncounterNote note_text"
    And ".ui-dialog-content" should contain text "Hello, your KPS is 100%."
    When I follow "Cancel"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "[Not set]"

  @javascript
  Scenario: User creating unknown abstraction
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text              |
      |Hello, your KPS is 100%.|
    When I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "unknown" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "unknown"
    And the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    When I follow "edit" within ".has_karnofsky_performance_status"
    Then "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should be checked
    And "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked

  @javascript
  Scenario: User creating unknown abstraction when unknown suggestion exists
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                 |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "unknown" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should be checked
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"

  @javascript
  @wip
  Scenario: User creating not applicable abstraction
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                  |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I check "not applicable" within the first ".abstractor_abstraction"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "not applicable"
    And the "Accepted" checkbox within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion" should not be checked
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should be checked
    Then "select.combobox" in the first ".abstractor_abstraction" should not contain selector "option[selected='selected']"
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked

  @javascript
  Scenario: User creating abstraction
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                 |
      |Hello, you look good to me.|
    And I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction" should not contain selector ".abstractor_abstraction_edit"
    And I should see "edit" anywhere within ".has_karnofsky_performance_status"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should not contain text "[Not set]"
    And the "Accepted" checkbox within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion" should not be checked
    When I follow "edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    Then "select.combobox" in the first ".abstractor_abstraction" should have "100% - Normal; no complaints; no evidence of disease." selected
    And "input#abstractor_abstraction_not_applicable" in the first ".abstractor_abstraction" should not be checked
    And "input#abstractor_abstraction_unknown" in the first ".abstractor_abstraction" should not be checked
    When I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "90% - Able to carry on normal activity; minor signs or symptoms of disease."
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "History"
    And ".abstractor_abstraction_value" in the first ".abstractor_abstraction" should contain text "100% - Normal; no complaints; no evidence of disease."

  @javascript
  Scenario: User creating abstraction when matching suggestion exists
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                            |
      | Hello, you look good to me. KPS: 100 |
    And I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status"
    And I wait for the ajax request to finish
    And I fill in "input.combobox" autocompleter within the first ".abstractor_abstraction" with "100% - Normal; no complaints; no evidence of disease."
    And I press "Save"
    And I wait for the ajax request to finish
    And the "Accepted" checkbox within the last ".has_karnofsky_performance_status .edit_abstractor_suggestion" should be checked

  @javascript
  Scenario: User setting the value of an abstraction schema with a date object type
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    And I follow "edit" within ".has_karnofsky_performance_status_date"
    And I wait for the ajax request to finish
    And I fill in "abstractor_abstraction_value" with "2014-06-03" within ".has_karnofsky_performance_status_date"
    And I press "Save"
    And I wait for the ajax request to finish
    Then ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should contain text "2014-06-03"

  @javascript
  Scenario: User setting all the values to 'not applicable' for an abstractable entitty
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should contain text "[Not set]"
    When I do not confirm link "Not applicable all" in the first ".abstractor_abstractions"
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "Accepted" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should not contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should not contain text "not applicable"
    When I confirm link "Not applicable all" in the first ".abstractor_abstractions"
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "Accepted" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "not applicable"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should contain text "not applicable"

  @javascript
  Scenario: User setting all the values to 'unknown' for an abstractable entitty
    Given abstraction schemas are set
    And encounter notes with the following information exist
      | Note Text                               |
      | Hello, I have no idea what is your KPS. |
    When I go to the last encounter note edit page
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "Accepted" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "[Not set]"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should contain text "[Not set]"
    When I do not confirm link "Unknown all" in the first ".abstractor_abstractions"
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should not be checked
    And the "Accepted" checkbox within ".has_karnofsky_performance_status_date" should not be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should not contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should not contain text "unknown"
    When I confirm link "Unknown all" in the first ".abstractor_abstractions"
    Then the "Accepted" checkbox within ".has_karnofsky_performance_status" should be checked
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status" should contain text "unknown"
    And ".abstractor_abstraction_value" in the first ".has_karnofsky_performance_status_date" should contain text "unknown"