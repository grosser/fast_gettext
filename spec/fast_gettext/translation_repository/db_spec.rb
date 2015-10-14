require 'spec_helper'
require 'active_record'
require 'fast_gettext/translation_repository/db'

FastGettext::TranslationRepository::Db.require_models

describe FastGettext::TranslationRepository::Db do
  before :all do
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => ":memory:"
    )

    #create model table
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(:version => 1) do
      create_table :translation_keys do |t|
        t.string :key, :unique=>true, :null=>false
        t.timestamps
      end

      create_table :translation_texts do |t|
        t.string :text, :locale
        t.integer :translation_key_id, :null=>false
        t.timestamps
      end
    end
  end

  before do
    TranslationKey.delete_all
    TranslationText.delete_all
    FastGettext.locale = 'de'
    @rep = FastGettext::TranslationRepository::Db.new('x', :model=>TranslationKey)
  end

  def create_translation(key, text)
    translation_key = TranslationKey.create!(:key => key)
    TranslationText.create!(:translation_key_id => translation_key.id, :text => text, :locale => "de")
  end

  it "reads locales from the db" do
    locales = ['de','en','es']
    locales.reverse.each do |locale|
      TranslationText.create!(:translation_key_id=>1, :text=>'asdasd', :locale=>locale)
    end
    @rep.available_locales.should == locales
  end

  it "has no pluralisation_rule by default" do
    @rep.pluralisation_rule.should == nil
  end

  it "cannot translate when no models are present" do
    @rep['car'].should == nil
  end

  it "can translate" do
    create_translation 'car', 'Auto'
    @rep['car'].should == 'Auto'
  end

  it "cannot pluralize when no model is present" do
    @rep.plural('Axis','Axis').should == []
  end

  it "can pluralize" do
    create_translation 'Axis||||Axis', 'Achse||||Achsen'
    @rep.plural('Axis','Axis').should == ['Achse','Achsen']
  end

  it "can ignore newline format" do
    create_translation "good\r\nmorning", "guten\r\nMorgen"
    @rep["good\nmorning"].should == "guten\r\nMorgen"
  end

  it "removes texts when key is removed" do
    t = create_translation("a", "b")
    lambda{
      lambda{
        t.translation_key.destroy
      }.should change{ TranslationText.count }.by(-1)
    }.should change{ TranslationKey.count }.by(-1)
  end

  it "expires the cache when updated" do
    FastGettext.should_receive(:expire_cache_for).with('car')
    translation_text = create_translation 'car', 'Auto'
    translation_text.update_attributes :text => 'Autobot'
  end
end
