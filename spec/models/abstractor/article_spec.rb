require 'spec_helper'
require './test/dummy/lib/setup/setup/'
describe Article do
  before(:each) do
    Abstractor::Setup.system
    list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
    v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
    source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
    @favorite_baseball_team_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_baseball_team', display_name: 'Favorite baseball team', abstractor_object_type: list_object_type, preferred_name: 'Favorite baseball team')
    abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 2)
    @abstractor_object_value_white_sox = FactoryGirl.create(:abstractor_object_value, value: 'White Sox')
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_white_sox)
    @abstractor_object_value_cubs = FactoryGirl.create(:abstractor_object_value,value: 'Cubs')
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_cubs)
    @abstractor_object_value_twins = FactoryGirl.create(:abstractor_object_value,value: 'Twins')
    Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_baseball_team_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_twins)
    Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
  end

  describe "querying by abstractor suggestion type" do
    it "can report what has an 'unknown' suggestion type", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
    end

    it "reports empty what has a 'unknown' suggestion type when there is a 'suggested' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to be_empty
    end

    it "reports not empty what has a 'unknown' suggestion type when there is a deleted 'suggested' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      @abstractor_object_value_white_sox.soft_delete!
      article.reload

      expect(article.abstractor_abstractions.map { |a| a.abstractor_suggestions.deleted }.size).to eq(1)
      expect(article.abstractor_abstractions.map { |a| a.abstractor_suggestions.not_deleted }.size).to eq(1)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
    end

    it "reports empty what has a 'suggested' suggestion type when there is a deleted 'suggested' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      @abstractor_object_value_white_sox.soft_delete!
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED)).to be_empty
    end

    it "can report what has a 'suggested' suggestion type", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED)).to eq([article])
    end


    it "reports empty what has a 'suggested' suggestion type when there is an 'unknown' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED)).to be_empty
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_baseball_team_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_white_sox.value, nil, nil, nil, nil)
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made and then its abstracto object value soft deleted", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_baseball_team_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_white_sox.value, nil, nil, nil, nil)
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      @abstractor_object_value_white_sox.soft_delete!
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN)).to eq([article])
    end
  end

  describe "querying by abstractor suggestion type (filtered)" do
    before(:each) do
      list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
      @abstractor_abstraction_schema_always_unknown = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: list_object_type, preferred_name: 'Always unknown')
      @abstractor_subject_abstraction_schema_always_unknown = Abstractor::AbstractorSubject.create(:subject_type => 'Article', :abstractor_abstraction_schema => @abstractor_abstraction_schema_always_unknown)
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_abstraction_schema_always_unknown, from_method: 'note_text', abstractor_abstraction_source_type: source_type_nlp_suggestion, :abstractor_rule_type => unknown_rule)
    end

    it "can report what has an 'unknown' suggestion type", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it "reports empty what has a 'unknown' suggestion type when there is a 'suggested' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it "reports what has a 'unknown' suggestion type when there is a 'suggested' suggestion thats abstractor object value is soft deleted", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      @abstractor_object_value_white_sox.soft_delete!
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it "can report what has a 'suggested' suggestion type", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it "reports empty what has a 'suggested' suggestion type when there is an 'unknown' suggestion", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it "reports empty what has a 'suggested' suggestion type when the abstractor object value is soft deleted", focus: false do
      article = FactoryGirl.create(:article, note_text: 'I love the white sox.  Minnie Minoso should be in the hall of fame.')
      article.abstract
      @abstractor_object_value_white_sox.soft_delete!
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_baseball_team_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_white_sox.value, nil, nil, nil, nil)
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made and its abstactor object value is soft deleted", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_baseball_team_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_white_sox.value, nil, nil, nil, nil)
      @abstractor_object_value_white_sox.soft_delete!
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_baseball_team_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end
  end

  describe "querying by abstractor suggestion (namespaced)" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @favorite_philosopher_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_philosopher', display_name: 'Favorite philosopher', abstractor_object_type: list_object_type, preferred_name: 'Favorite philosopher')
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
      @abstractor_object_value_rorty = FactoryGirl.create(:abstractor_object_value, value: 'Rorty')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_rorty)
      @abstractor_object_value_wittgenstein = FactoryGirl.create(:abstractor_object_value,value: 'Wittgenstein')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_wittgenstein)
      @abstractor_object_value_dennet = FactoryGirl.create(:abstractor_object_value,value: 'Dennet')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_dennet)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    end

    it "can report what has an 'unknown' suggestion type (namespaced)", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1)).to eq([article])
    end

    it "reports empty what has a 'unknown' suggestion type when there is a suggested suggestion (namespaced)", focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1)).to be_empty
    end

    it "can report what has a 'suggested' suggestion type (namespaced)", focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1)).to eq([article])
    end

    it "reports empty what has a 'suggested' suggestion type when there is an 'unknown' suggestion (namespaced)", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1)).to be_empty
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_philosopher_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_rorty.value, nil, nil, nil, nil)
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [])).to be_empty
    end
  end

  describe "querying by abstractor suggestion (namespaced) (filtered)" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
      unknown_rule = Abstractor::AbstractorRuleType.where(name: 'unknown').first
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @favorite_philosopher_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_philosopher', display_name: 'Favorite philosopher', abstractor_object_type: list_object_type, preferred_name: 'Favorite philosopher')
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
      @abstractor_object_value_rorty = FactoryGirl.create(:abstractor_object_value, value: 'Rorty')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_rorty)
      @abstractor_object_value_wittgenstein = FactoryGirl.create(:abstractor_object_value, value: 'Wittgenstein')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_wittgenstein)
      @abstractor_object_value_dennet = FactoryGirl.create(:abstractor_object_value, value: 'Dennet')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_dennet)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
      @abstractor_abstraction_schema_always_unknown = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_always_unknown', display_name: 'Always unknown', abstractor_object_type: list_object_type, preferred_name: 'Always unknown')
      @abstractor_subject_abstraction_schema_always_unknown = Abstractor::AbstractorSubject.create(:subject_type => 'Article', :abstractor_abstraction_schema => @abstractor_abstraction_schema_always_unknown, namespace_type: 'Discerner::Search', namespace_id: 1)
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: @abstractor_subject_abstraction_schema_always_unknown, from_method: 'note_text', abstractor_abstraction_source_type: source_type_nlp_suggestion, :abstractor_rule_type => unknown_rule)
    end

    it 'can report what has an unknown suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'reports empty what has a unknown suggestion type when there is a suggested suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_UNKNOWN, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to eq([article])
    end

    it 'can report what has a suggested suggestion type (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'Richard Rorty was facile. But very entertaining.')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to eq([article])
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it 'reports empty what has a suggested suggestion type when there is an unknown suggestion (namespaced)', focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload

      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end

    it "reports what has an 'unknown' suggestion type, even when a manual suggestion is made", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article.reload
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      abstractor_abstraction = article.reload.detect_abstractor_abstraction(@favorite_philosopher_abstractor_abstraction_schema)
      expect(abstractor_abstraction.abstractor_suggestions.size).to eq(1)
      abstractor_abstraction.abstractor_subject.suggest(abstractor_abstraction, nil, nil, nil, nil, nil, nil, nil, @abstractor_object_value_rorty.value, nil, nil, nil, nil)
      expect(abstractor_abstraction.reload.abstractor_suggestions.size).to eq(2)
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@favorite_philosopher_abstractor_abstraction_schema])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
      expect(Article.by_abstractor_suggestion_type(Abstractor::Enum::ABSTRACTION_SUGGESTION_TYPE_SUGGESTED, namespace_type: 'Discerner::Search', namespace_id: 1, abstractor_abstraction_schemas: [@abstractor_abstraction_schema_always_unknown])).to be_empty
    end
  end

  describe "querying by workflow status" do
    before(:each) do
      Abstractor::Setup.system
      list_object_type = Abstractor::AbstractorObjectType.where(value: 'list').first
      v_rule = Abstractor::AbstractorRuleType.where(name: 'value').first
      source_type_nlp_suggestion = Abstractor::AbstractorAbstractionSourceType.where(name: 'nlp suggestion').first
      @favorite_philosopher_abstractor_abstraction_schema = Abstractor::AbstractorAbstractionSchema.create(predicate: 'has_favorite_philosopher', display_name: 'Favorite philosopher', abstractor_object_type: list_object_type, preferred_name: 'Favorite philosopher')
      abstractor_subject = Abstractor::AbstractorSubject.create(subject_type: 'Article', abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, namespace_type: 'Discerner::Search', namespace_id: 1)
      @abstractor_object_value_rorty = FactoryGirl.create(:abstractor_object_value, value: 'Rorty')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_rorty)
      @abstractor_object_value_wittgenstein = FactoryGirl.create(:abstractor_object_value, value: 'Wittgenstein')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_wittgenstein)
      @abstractor_object_value_dennet = FactoryGirl.create(:abstractor_object_value, value: 'Dennet')
      Abstractor::AbstractorAbstractionSchemaObjectValue.create(abstractor_abstraction_schema: @favorite_philosopher_abstractor_abstraction_schema, abstractor_object_value: @abstractor_object_value_dennet)
      Abstractor::AbstractorAbstractionSource.create(abstractor_subject: abstractor_subject, from_method: 'note_text', abstractor_rule_type: v_rule, abstractor_abstraction_source_type: source_type_nlp_suggestion)
    end


    it "can report against all workflow statuses", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract

      article_2 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_2.abstract
      article_2.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.save!
      end

      article_3 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_3.abstract
      article_3.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.save!
      end

      expect(Article.by_abstraction_workflow_status('All')).to eq([article, article_2,  article_3])
      expect(Article.by_abstraction_workflow_status(nil)).to eq([article, article_2,  article_3])
    end

    it "can report what has a 'pending' workflow status", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract

      article_2 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_2.abstract
      article_2.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.save!
      end

      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_PENDING)).to eq([article])

      article_3 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_3.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

      article_4 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_4.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

      options = { namespace_type: 'Discerner::Search', namespace_id: 2 }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_PENDING, options)).to eq([article, article_4])
    end

    it "can report what has a 'submitted' workflow status", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.workflow_status_whodunnit = 'little my'
        abstractor_abstraction.save!
      end

      article_2 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED)).to eq([article])

      article_3 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_3.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article_3.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      article_4 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_4.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

      article_4.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      options = { workflow_status_whodunnit: 'moominpapa' }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED, options)).to eq([article_3, article_4])

      options = { workflow_status_whodunnit: 'moominpapa', namespace_type: 'Discerner::Search', namespace_id: 2 }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED, options)).to eq([article_4])
    end

    it "can report what has a 'discarded' workflow status", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.workflow_status_whodunnit = 'little my'
        abstractor_abstraction.save!
      end

      article_2 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED)).to eq([article])

      article_3 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_3.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article_3.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      article_4 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_4.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)

      article_4.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      options = { workflow_status_whodunnit: 'moominpapa' }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED, options)).to eq([article_3, article_4])

      options = { workflow_status_whodunnit: 'moominpapa', namespace_type: 'Discerner::Search', namespace_id: 2 }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED, options)).to eq([article_4])
    end

    it "can report what has a 'submitted or discarded' workflow status", focus: false do
      article = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article.abstract
      article.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.workflow_status_whodunnit = 'little my'
        abstractor_abstraction.save!
      end

      article_2 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_2.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article_2.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.workflow_status_whodunnit = 'little my'
        abstractor_abstraction.save!
      end

      article_3 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_3.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)

      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED_OR_DISCARDED)).to match_array([article, article_2])

      article_4 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_4.abstract(namespace_type: 'Discerner::Search', namespace_id: 2)
      article_4.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.value = 'moomin'
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      article_5 = FactoryGirl.create(:article, note_text: 'gobbledy gook')
      article_5.abstract(namespace_type: 'Discerner::Search', namespace_id: 1)
      article_5.reload.abstractor_abstractions.each do |abstractor_abstraction|
        abstractor_abstraction.workflow_status = Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_DISCARDED
        abstractor_abstraction.workflow_status_whodunnit = 'moominpapa'
        abstractor_abstraction.save!
      end

      options = { workflow_status_whodunnit: 'moominpapa' }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED_OR_DISCARDED, options)).to eq([article_4, article_5])

      options = { workflow_status_whodunnit: 'moominpapa', namespace_type: 'Discerner::Search', namespace_id: 2 }
      expect(Article.by_abstraction_workflow_status(Abstractor::Enum::ABSTRACTION_WORKFLOW_STATUS_SUBMITTED_OR_DISCARDED, options)).to eq([article_4])
    end
  end
end