Then(/^I should see (\d+) "(.*?)" within(?: the (first|last))? "(.*?)"$/) do |count, selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector, :visible => true).size.should eq(count.to_i)
  }
end

Then /^the "([^"]*)" radio button within(?: the (first|last))? "([^\"]*)" should be checked$/ do |label, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_truthy
    else
      assert field_checked
    end
  }
end

When /^(?:|I )choose "([^"]*)" within(?: the (first|last))? "(.*?)"$/ do |field, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    choose(field)
  }
end

When /^(?:|I )fill in "([^"]*)" with "([^"]*)" within(?: the (first|last))? "(.*?)"$/ do |field, value, position, parent|
  position ||= 'first'
  within_scope(get_scope(position, parent)) {
    fill_in(field, :with => value)
  }
end


# When /^(?:|I )check "([^"]*)" within "(.*?)"$/ do |field, parent|
#   within(parent) do
#     check(field)
#   end
# end

When(/^I select "(.*?)" from "(.*?)" within "(.*?)"$/) do |value, field, parent|
  within(parent) do
    select(value, :from => field)
  end
end

When /^I wait for the ajax request to finish$/ do
  start_time = Time.now
  page.evaluate_script('jQuery.isReady&&jQuery.active==0').class.should_not eql(String) until page.evaluate_script('jQuery.isReady&&jQuery.active==0') or (start_time + 5.seconds) < Time.now do
    sleep 1
  end
end

When /^I press "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    page.evaluate_script('window.confirm = function() { return true; }')
    click_button(selector)
  }
end

When /^I enter "([^\"]*)" into "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |value, selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.set(value) }
  }
end

When /^I focus|click on "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector, :visible => true).each{ |e| e.click }
  }
  steps %Q{
    When I wait 2 seconds
  }
end

When /^I follow "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    steps %Q{
      When I follow "#{selector}"
    }
  }
end

When /^I follow "([^\"]*)" within(?: the (first|last))? "([^\"]*)" and accept confirm$/ do |selector, position, scope_selector|
  accept_confirm do
    within_scope(get_scope(position, scope_selector)) {
      steps %Q{
        When I follow "#{selector}"
      }
    }
  end
end

When /^I fill in "([^\"]*)" autocompleter within(?: the (first|last))? "([^\"]*)" with "([^\"]*)"$/ do |selector, position, scope_selector, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    all(selector).each{|e| e.set(value)}
    menuitem = '.ui-menu-item a:contains(\"' + value + '\")'
    page.execute_script " $('#{menuitem}').trigger(\"mouseenter\").click();"
  }
end

When /^I select "([^\"]*)" from "([^\"]*)" in(?: the (first|last))? "([^\"]*)"$/ do |value, selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    find(selector, :visible => true).should_not be_blank
    find(selector, :visible => true).select(value)
  }
end

When /^I confirm link "([^"]*)"(?: in the(?: (first|last)?) "([^\"]*)")?$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    page.evaluate_script('window.confirm = function() { return true; }')
    steps %Q{
      When I follow "#{selector}"
    }
  }
end

When /^I do not confirm link "([^"]*)"(?: in the(?: (first|last)?) "([^\"]*)")?$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    page.evaluate_script('window.confirm = function() { return false; }')
    steps %Q{
      When I follow "#{selector}"
    }
  }
end

When /^I confirm "([^"]*)"$/ do |selector|
  page.evaluate_script('window.confirm = function() { return true; }')
  steps %Q{
    When I press "#{selector}"
  }
end

When /^I wait (\d+) seconds$/ do |wait_seconds|
  sleep(wait_seconds.to_i)
end

When /^(?:|I )click within "([^"]*)" \(XPath\)$/ do |selector|
  find(:xpath, selector).click
end

When /^(?:|I )click within first "([^"]*)"$/ do |selector|
  first(selector).click
end

When /^(?:|I )click within last "([^"]*)"$/ do |selector|
  all(selector).last.click
end

When /^(?:|I )click within "([^"]*)"$/ do |selector|
  find(selector).click
end

When /^(?:|I )press the (?:Enter|Return) key in "([^"]*)"$/ do |field|
  keypress_script = "var e = $.Event('keydown', { keyCode: 13 }); $('##{field}').trigger(e);"
  page.driver.browser.execute_script(keypress_script)
end

# When /^(?:|I )press the (Enter|Return) key in "([^"]*)"$/ do |key, field|
#  find(field).native.send_keys :enter
# end

When /^(?:|I )follow element "([^"]*)"$/ do |path|
  page.find(:xpath, path).click
end

Then(/^I should see "(.*?)" within(?: the (first|last))? "(.*?)"$/) do |regexp, position, selector|
position ||= 'first'
  regexp = Regexp.new(regexp)
  within_scope(get_scope(position, selector)) {
    if page.respond_to? :should
      page.should have_xpath('//*', :text => regexp, :visible => true )
    else
      assert page.has_xpath?('//*', :text => regexp, :visible => :true)
    end
  }
end

Then(/^I should not see "(.*?)" within(?: the (first|last))? "(.*?)"$/) do |regexp, position, selector|
  position ||= 'first'
  regexp = Regexp.new(regexp)

  within_scope(get_scope(position, selector)) {
    if page.respond_to? :should
      page.should have_no_xpath('//*', :text => regexp, :visible => true )
    else
      assert page.has_no_xpath?('//*', :text => regexp, :visible => true)
    end
  }
end

Then(/^I should see (\d+) "(.*?)" rows$/) do |count, selector|
  all(selector).size.should == count.to_i
end

Then /^the "([^"]*)" field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = find_field(field)
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea' && field.value.blank?) ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" disabled field(?: within (.*))? should contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = page.all("#{field}", :visible => true).first
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea' && field.value.blank?) ? field.text : field.value
    if field_value.respond_to? :should
      field_value.should =~ /#{value}/
    else
      assert_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" disabled field(?: within (.*))? should not contain "([^"]*)"$/ do |field, parent, value|
  with_scope(parent) do
    field = page.all("#{field}", :visible => true).first
    field.should_not be_blank
    field_value = (field.tag_name == 'textarea') ? field.text : field.value
    if field_value.respond_to? :should_not
      field_value.should_not =~ /#{value}/
    else
      assert_no_match(/#{value}/, field_value)
    end
  end
end

Then /^the "([^"]*)" radio button(?: within (.*))? should not be checked$/ do |label, parent|
  with_scope(parent) do
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_falsey
    else
      assert !field_checked
    end
  end
end


Then /^the "([^"]*)" checkbox within(?: the (first|last))? "([^\"]*)" should( not)? be present$/ do |label, position, scope_selector, negate|
  within_scope(get_scope(position, scope_selector)) {
    expectation = negate ? :should_not : :should
    begin
      field = find_field(label)
    rescue Capybara::ElementNotFound
    end
    field.send(expectation, be_present)
  }
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  uri = URI.parse(current_url)
  current_path = uri.path
  current_path += "?#{uri.query}" unless uri.query.blank?
  if current_path.respond_to? :should
    current_path.gsub(/\?.*$/, '').should == path_to(page_name).gsub(/\?.*$/, '')
  else
    assert_equal path_to(page_name), current_path
  end
end

Then /the element "([^\"]*)" should be hidden$/ do |selector|
  page.evaluate_script("$('#{selector}').is(':hidden');").should be_truthy
end

Then /the element "([^\"]*)" should not be hidden$/ do |selector|
  page.evaluate_script("$('#{selector}').is(':not(:hidden)');").should be_truthy
end

Then /^"([^"]*)" should be selected for "([^"]*)"(?: within "([^\"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    field_labeled(field).find(:xpath, ".//option[@selected = 'selected'][text() = '#{value}']").should be_present
  end
end

Then /^I should see an? "([^"]*)" element$/ do |selector|
  find(selector).should be_present
end

Then /^I should not see an? "([^"]*)" element$/ do |selector|
  page.evaluate_script("$(\"#{selector}\");").should be_empty
end

Then /^the element "([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? be visible$/ do |selector, position, scope_selector, negation|
  within_scope(get_scope(position, scope_selector)) {
    if negation.blank?
      all(selector).should_not be_empty
      find(selector).should be_visible
    else
      all(selector, :visible => true).length.should == 0
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain "([^\"]*)"$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.value.should == value}
    else
      all(selector, :visible => true).each{ |e| e.value.should_not == value}
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain selector "([^\"]*)"$/ do |selector, position, scope_selector, negation, inner_selector|
  within_scope(get_scope(position, scope_selector)) {
    if negation.blank?
      all("#{selector} #{inner_selector}").should_not be_empty
    else
      all("#{selector} #{inner_selector}").should be_empty
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? have "([^\"]*)" selected$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    selector = "#{selector} option[selected='selected']"
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.text.should == value }
    else
      all(selector, :visible => true).each{ |e| e.text.should_not == value }
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? be checked$/ do |selector, position, scope_selector, negation|
  within_scope(get_scope(position, scope_selector)) {
    selector = "#{selector}[checked='checked']"
    if negation.blank?
      all(selector, :visible => true).should_not be_empty
    else
      all(selector, :visible => true).should be_empty
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? be checked and should be disabled$/ do |selector, position, scope_selector, negation|
  expect(all("#{scope_selector}")[0].find_field(selector, disabled: true)).to be_truthy
end

Then /^"([^\"]*)"(?: in the (first|last) "([^\"]*)")? should(?: (not))? have options "([^\"]*)"$/ do |selector, position, scope_selector, negation, options|
  within_scope(get_scope(position, scope_selector)) {
    elements = all(selector)
    elements.should_not be_empty
    options.split(', ').each do |o|
      if negation.blank?
        all(selector).each{ |e| e.find(:xpath, ".//option[text()[contains(.,'#{o}')]]").should be_present }
      else
        elements.each{ |e| expect{e.find(:xpath, ".//option[text()[contains(.,'#{o}')]]")}.to raise_error }
      end
    end
  }
end

Then /^"([^\"]*)"(?: in the(?: (first|last)?) "([^\"]*)")? should(?: (not))? contain text "([^\"]*)"$/ do |selector, position, scope_selector, negation, value|
  within_scope(get_scope(position, scope_selector)) {
    all(selector).should_not be_empty
    if negation.blank?
      all(selector, :visible => true).each{ |e| e.should have_content(value) }
    else
      all(selector, :visible => true).each{ |e| e.should_not have_content(value) }
    end
  }
end

def within_scope(locator)
  locator ? within(locator) { yield } : yield
end

def get_scope(position, scope_selector)
  return unless scope_selector
  items = page.all("#{scope_selector}")
  case position
  when 'first'
    item = items.first
  when 'last'
    item = items.last
  else
    item = items.last
  end
  item
end

Given /^abstraction schemas are set$/ do
  Abstractor::Setup.system
  Setup.encounter_note
  Setup.sites
  Setup.custom_site_synonyms
  Setup.site_categories
  Setup.laterality
  Setup.radiation_therapy_prescription
  Setup.pathology_case
  Setup.surgery
  Setup.imaging_exam
end

Then(/^I should see "(.*?)" anywhere within(?: the (first|last))? "(.*?)"$/) do |text, position, selector|
  position ||= 'first'
  expect(all(selector).send(position).text.scan(text).any?).to be_truthy
end

Then(/^I should not see "(.*?)" anywhere within(?: the (first|last))? "(.*?)"$/) do |text, position, selector|
  position ||= 'first'
  expect(all(selector).send(position).text.scan(text).any?).to be_falsy
end

When /^I check "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    check(selector)
  }
end

When /^I uncheck "([^\"]*)" within(?: the (first|last))? "([^\"]*)"$/ do |selector, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    uncheck(selector)
  }
end

When /^I check "([^\"]*)" within(?: the (first|last))? "([^\"]*)" containing text "([^\"]*)"$/ do |selector, position, scope_selector, text|
  within_scope(get_scope(position, scope_selector)) {
    begin
      if have_content(text)
        check(selector)
      end
    rescue Capybara::ElementNotFound
    end
  }
end

Then /^the "([^"]*)" checkbox within(?: the (first|last))? "([^\"]*)" should be checked$/ do |label, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_truthy
    else
      assert field_checked
    end
  }
end

Then /^the "([^"]*)" checkbox within(?: the (first|last))? "([^\"]*)" should not be checked$/ do |label, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    field_checked = find_field(label)['checked']
    if field_checked.respond_to? :should
      field_checked.should be_falsey
    else
      assert !field_checked
    end
  }
end

Given(/^workflow status is enabled on the "(.*?)"  with "(.*?)" as the submit label and "(.*?)" as the pend label$/) do |abstractor_subject_group_name, submit_label, pend_label|
  abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: abstractor_subject_group_name).first
  abstractor_subject_group.enable_workflow_status = true
  abstractor_subject_group.workflow_status_submit = submit_label
  abstractor_subject_group.workflow_status_pend = pend_label
  abstractor_subject_group.save!
end

Given(/^workflow status is not enabled on the "(.*?)"$/) do |abstractor_subject_group_name|
  abstractor_subject_group = Abstractor::AbstractorSubjectGroup.where(name: abstractor_subject_group_name).first
  abstractor_subject_group.enable_workflow_status = false
  abstractor_subject_group.save!
end

Then /^the "([^"]*)" button within(?: the (first|last))? "([^\"]*)" should( not)? be present$/ do |locator, position, scope_selector, negate|
  within_scope(get_scope(position, scope_selector)) {
    expectation = negate ? :should_not : :should
    begin
      button = find(locator, visible: true)
    rescue Capybara::ElementNotFound
    end
    button.send(expectation, be_present)
  }
end

Then /^the "([^"]*)" button within(?: the (first|last))? "([^\"]*)" should( not)? be disabled$/ do |locator, position, scope_selector, negate|
  within_scope(get_scope(position, scope_selector)) {
    expectation = negate ? :should_not : :should
    begin
      button = find(locator)
    rescue Capybara::ElementNotFound
    end
    button['disabled'].send(expectation, be_truthy)
  }
end

Then /^the "([^"]*)" checkbox within(?: the (first|last))? "([^\"]*)" should be disabled$/ do |locator, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    begin
      checkbox = find_field(locator, disabled: true )
    rescue Capybara::ElementNotFound
    end
    checkbox['disabled'].should be_truthy
  }
end

Then /^the "([^"]*)" checkbox within(?: the (first|last))? "([^\"]*)" should not be disabled$/ do |locator, position, scope_selector|
  within_scope(get_scope(position, scope_selector)) {
    begin
      checkbox = find_field(locator, disabled: false )
    rescue Capybara::ElementNotFound
    end
    checkbox['disabled'].should be_falsey
  }
end