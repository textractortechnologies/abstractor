Given /^abstractor rules with the following information exist$/ do |table|
  table.hashes.each_with_index do |rule_hash, i|
    rule = FactoryGirl.build(:abstractor_rule, name: rule_hash['Name'], rule: rule_hash['Rule'], description: rule_hash['Description'])
    rule_hash['Abstractor abstraction schema'].split(',').each do |abstractor_abstraction_schema_predicate|
      abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.where(predicate: abstractor_abstraction_schema_predicate.strip).first
      abstractor_subject = Abstractor::AbstractorSubject.where(subject_type: rule_hash['Abstractor subject'], abstractor_abstraction_schema_id: abstractor_abstraction_schema.id)
      rule.abstractor_subjects << abstractor_subject
    end
    rule.save!
  end
end


Then(/^I should see the following abstractor rules$/) do |table|
  table.hashes.each_with_index do |abstractor_rule_hash, i|
    expect(all(".abstractor_rule")[i].find('.abstractor_rule_name')).to have_content(abstractor_rule_hash['Name'])
    expect(all(".abstractor_rule")[i].find('.abstractor_rule_abstractor_subjects')).to have_content(abstractor_rule_hash['Abstractor subjects'])
  end
end

Then(/^I follow 'Edit' within the abstractor rule named "([^"]*)"$/) do |abstractor_rule_name|
  abstractor_rule = Abstractor::AbstractorRule.where(name: abstractor_rule_name).first
  all("#abstractor_rule_#{abstractor_rule.id}")[0].find('.edit_abstractor_rule_link').click
end

Then(/^the "([^"]*)" select should have "([^"]*)" chosen$/) do |select_name, selected_value|
  expect(page.has_select?(select_name, selected: selected_value)).to be_truthy
end