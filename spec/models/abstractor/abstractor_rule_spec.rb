require 'spec_helper'
describe  Abstractor::AbstractorAbstraction do
  before(:each) do
    Abstractor::Setup.system
    abstractor_object_type = Abstractor::AbstractorObjectType.first
    abstractor_rule_type = Abstractor::AbstractorRuleType.first

    abstractor_abstraction_schema_1 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
    @abstractor_subject_1 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    abstractor_abstraction_schema_1.abstractor_subjects << @abstractor_subject_1

    abstractor_abstraction_schema_2 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property_2', display_name: 'some_property_2', abstractor_object_type: abstractor_object_type, preferred_name: 'property_2')
    @abstractor_subject_2 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    abstractor_abstraction_schema_2.abstractor_subjects << @abstractor_subject_2

    abstractor_abstraction_schema_3 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property_3', display_name: 'some_property_3', abstractor_object_type: abstractor_object_type, preferred_name: 'property_3')
    @abstractor_subject_3 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    abstractor_abstraction_schema_3.abstractor_subjects << @abstractor_subject_3

    abstractor_abstraction_schema_4 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property_4', display_name: 'some_property_4', abstractor_object_type: abstractor_object_type, preferred_name: 'property_4')
    @abstractor_subject_4 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    abstractor_abstraction_schema_4.abstractor_subjects << @abstractor_subject_4

    @abstractor_rule_1 = FactoryGirl.build(:abstractor_rule, rule: 'foo rule')
    @abstractor_rule_1.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_1)
    @abstractor_rule_1.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_2)
    @abstractor_rule_1.save!

    @abstractor_rule_2 = FactoryGirl.build(:abstractor_rule, rule: 'foo rule 2')
    @abstractor_rule_2.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_3)
    @abstractor_rule_2.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_4)
    @abstractor_rule_2.save!
  end

  it 'can search for abstractor rules by abstractor subject', focus: false do
    expect(Abstractor::AbstractorRule.search_by_abstractor_subjects_ids([@abstractor_subject_1.id, @abstractor_subject_2.id])).to match_array([@abstractor_rule_1])
  end

  describe 'updating timestamps on linked records' do
    it 'updates abstractor_rule_abstractor_subjects on update' do
      old_date_1 = @abstractor_rule_1.abstractor_rule_abstractor_subjects.first.updated_at
      old_date_2 = @abstractor_rule_1.abstractor_rule_abstractor_subjects.last.updated_at
      @abstractor_rule_1.name = 'Rule of rules'
      @abstractor_rule_1.save
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.first.updated_at).not_to eq old_date_1
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.last.updated_at).not_to eq old_date_2
    end

    it 'updates abstractor_rule_abstractor_subjects on touch' do
      old_date_1 = @abstractor_rule_1.abstractor_rule_abstractor_subjects.first.updated_at
      old_date_2 = @abstractor_rule_1.abstractor_rule_abstractor_subjects.last.updated_at
      @abstractor_rule_1.touch
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.first.updated_at).not_to eq old_date_1
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.last.updated_at).not_to eq old_date_2
    end
  end

  describe 'setting abstractor subjects' do
    it 'allows to set abstractor subjects' do
      expect(@abstractor_rule_1.abstractor_subjects_not_deleted_ids).to eq [@abstractor_subject_1.id, @abstractor_subject_2.id]
      @abstractor_rule_1.abstractor_subjects_not_deleted_ids = [@abstractor_subject_1.id]
      @abstractor_rule_1.save
      expect(@abstractor_rule_1.abstractor_subjects_not_deleted_ids).to eq [@abstractor_subject_1.id]
      expect(@abstractor_rule_1.abstractor_subject_ids).to eq [@abstractor_subject_1.id, @abstractor_subject_2.id]
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.where(abstractor_subject_id: @abstractor_subject_2.id).length).to eq 1
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.where(abstractor_subject_id: @abstractor_subject_2.id).last.deleted_at).not_to be_blank
      
      @abstractor_rule_1.abstractor_subjects_not_deleted_ids = [@abstractor_subject_1.id, @abstractor_subject_2.id]
      @abstractor_rule_1.save
      expect(@abstractor_rule_1.abstractor_subjects_not_deleted_ids).to eq [@abstractor_subject_1.id, @abstractor_subject_2.id]
      expect(@abstractor_rule_1.abstractor_subject_ids).to eq [@abstractor_subject_1.id, @abstractor_subject_2.id, @abstractor_subject_2.id]
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.where(abstractor_subject_id: @abstractor_subject_2.id).length).to eq 2
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.where(abstractor_subject_id: @abstractor_subject_2.id).first.deleted_at).not_to be_blank
      expect(@abstractor_rule_1.abstractor_rule_abstractor_subjects.where(abstractor_subject_id: @abstractor_subject_2.id).last.deleted_at).to be_blank

    end
  end
end