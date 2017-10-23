require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Abstractor::AbstractorRulesController, :type => :request do
  let(:accept_json) { { "Accept" => "application/json" } }
  let(:json_content_type) { { "Content-Type" => "application/json" } }
  let(:accept_and_return_json) { accept_json.merge(json_content_type) }

  before(:each) do
    Abstractor::Setup.system
    abstractor_object_type = Abstractor::AbstractorObjectType.first
    abstractor_rule_type = Abstractor::AbstractorRuleType.first

    @abstractor_abstraction_schema_1 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property', display_name: 'some_property', abstractor_object_type: abstractor_object_type, preferred_name: 'property')
    @abstractor_subject_1 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    @abstractor_abstraction_schema_1.abstractor_subjects << @abstractor_subject_1

    @abstractor_abstraction_schema_2 = FactoryGirl.create(:abstractor_abstraction_schema, predicate: 'has_some_property_2', display_name: 'some_property_2', abstractor_object_type: abstractor_object_type, preferred_name: 'property_2')
    @abstractor_subject_2 = FactoryGirl.build(:abstractor_subject, subject_type: 'Foo')
    @abstractor_abstraction_schema_2.abstractor_subjects << @abstractor_subject_2

    @rule = 'foo rule'
    @rule_name = 'foo rule name'
    @abstractor_rule_1 = FactoryGirl.build(:abstractor_rule, rule: @rule, name: @rule_name)
    @abstractor_rule_1.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_1)
    @abstractor_rule_1.abstractor_rule_abstractor_subjects.build(abstractor_subject: @abstractor_subject_2)
    @abstractor_rule_1.save!
  end

  describe "GET /abstractor_rules/" do
    it "return abstractor rules", focus: false do
      get "/abstractor_rules/?abstractor_subject_ids[]=#{@abstractor_subject_1.id}&abstractor_subject_ids[]=#{@abstractor_subject_2.id}", {}, accept_json

      expect(response.status).to be 200
      body = JSON.parse(response.body)
      expect(body['abstractor_rules'].size).to eq(1)
      expect(body['abstractor_rules'].first['rule']).to eq(@rule)
      expect(body['abstractor_rules'].first['abstractor_abstraction_schemas'].size).to eq(2)
      expect(body['abstractor_rules'].first['abstractor_abstraction_schemas'].first).to eq({"predicate"=>"#{@abstractor_abstraction_schema_1.predicate}", "display_name"=>"#{@abstractor_abstraction_schema_1.display_name}", "abstractor_abstraction_schema_id"=>@abstractor_abstraction_schema_1.id, "abstractor_subject_id"=>@abstractor_subject_1.id})
      expect(body['abstractor_rules'].first['abstractor_abstraction_schemas'].last).to eq({"predicate"=>"#{@abstractor_abstraction_schema_2.predicate}", "display_name"=>"#{@abstractor_abstraction_schema_2.display_name}", "abstractor_abstraction_schema_id"=>@abstractor_abstraction_schema_2.id, "abstractor_subject_id"=>@abstractor_subject_2.id})
    end

    it 'return abstractor rules (but not soft deleted ones)', focus: false do
      @abstractor_rule_1.soft_delete!
      get "/abstractor_rules/?abstractor_subject_ids[]=#{@abstractor_subject_1.id}&abstractor_subject_ids[]=#{@abstractor_subject_2.id}", {}, accept_json
      expect(response.status).to be 200
      body = JSON.parse(response.body)
      expect(body['abstractor_rules'].size).to eq(0)
    end
  end
end