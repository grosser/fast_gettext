current_folder = File.dirname(__FILE__)
require File.join(current_folder,'..','..','spec_helper')

class MockRepo
  def [](key)
    singular key
  end
end

describe 'FastGettext::TranslationRepository::Chain' do
  describe "empty chain" do
    before do
      @rep = FastGettext::TranslationRepository.build('chain', :chain=>[], :type=>:chain)
    end

    it "can be built" do
      @rep.available_locales.should == []
    end

    it "cannot translate" do
      @rep['car'].should == nil
    end

    it "cannot pluralize" do
      @rep.plural('Axis','Axis').should == []
    end

    it "stores pluralisation rule" do
      @rep.pluralisation_rule = lambda{|n|n+1}
      @rep.pluralisation_rule.call(3).should == 4
    end
  end

  describe "filled chain" do
    before do
      @one = MockRepo.new
      @one.stub!(:singular).with('xx').and_return 'one'
      @two = MockRepo.new
      @two.stub!(:singular).with('xx').and_return 'two'
      @rep = FastGettext::TranslationRepository.build('chain', :chain=>[@one, @two], :type=>:chain)
    end

    describe :singular do
      it "uses the first repo in the chain if it responds" do
        @rep['xx'].should == 'one'
      end

      it "uses the second repo in the chain if the first does not respond" do
        @one.should_receive(:singular).and_return nil
        @rep['xx'].should == 'two'
      end
    end

    describe :plural do
      it "uses the first repo in the chain if it responds" do
        @one.should_receive(:plural).with('a','b').and_return ['A','B']
        @rep.plural('a','b').should == ['A','B']
      end

      it "uses the second repo in the chain if the first does not respond" do
        @one.should_receive(:plural).with('a','b').and_return [nil,nil]
        @two.should_receive(:plural).with('a','b').and_return ['A','B']
        @rep.plural('a','b').should == ['A','B']
      end
    end
  end
end