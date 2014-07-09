RSpec::Matchers.define :be_accessible do |attribute|
  match do |response|
    response.class.accessible_attributes.include?(attribute.to_s)
  end
  description { "be accessible :#{attribute}" }
  failure_message { ":#{attribute} should be accessible" }
  failure_message_when_negated { ":#{attribute} should not be accessible" }
end
