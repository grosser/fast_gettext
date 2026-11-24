# frozen_string_literal: true

require "spec_helper"
require "tmpdir"

describe FastGettext::PluralExpression do
  # The Plural-Forms of the languages the item names, from the gettext manual.
  LANGUAGE_RULES = {
    "en" => "n != 1",
    "fr" => "n > 1",
    "ru" => "n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2",
    "ar" => "n==0 ? 0 : n==1 ? 1 : n==2 ? 2 : n%100>=3 && n%100<=10 ? 3 : n%100>=11 ? 4 : 5",
    "pl" => "n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2",
    "ja" => "0",
    "gem" => "n<3?n:0"
  }.freeze

  it "selects the same plural index as the expression it replaces" do
    LANGUAGE_RULES.each do |language, expression|
      released = ->(n) { eval(expression) } # rubocop:disable Security/Eval
      parsed = described_class.compile(expression)
      (0..300).each do |n|
        parsed.call(n).should == released.call(n)
      end
    end
  end

  it "parses every operator in the grammar" do
    expression = "n + 1 - 2 * 3 / 4 % 5 == 0 || !n && -n >= 1 ? 1 : 0"
    released = ->(n) { eval(expression) } # rubocop:disable Security/Eval
    parsed = described_class.compile(expression)
    (0..10).each { |n| parsed.call(n).should == released.call(n) }
    described_class.compile("+n <= 3 && n != 2").call(2).should == false
  end

  it "does not run code in the expression" do
    marker = File.join(Dir.tmpdir, "plural-expression-#{Process.pid}")
    File.unlink(marker) if File.exist?(marker)
    -> { described_class.compile("(File.write(#{marker.dump}, 'ran') && 0)") }.
      should raise_error(FastGettext::PluralExpression::InvalidExpression)
    File.exist?(marker).should == false
  end

  it "refuses anything outside the grammar" do
    [
      "(File.write('/tmp/plural-x', 'ran') && 0)",
      "`touch /tmp/plural-x`",
      "%x(touch /tmp/plural-x)",
      "n.to_s",
      "n.send(:to_s)",
      "Object::File",
      "'a'",
      ":a",
      "a",
      "n ? 1",
      "(n",
      "n)",
      "",
      nil,
      1.5
    ].each do |rule|
      -> { described_class.compile(rule) }.should raise_error(FastGettext::PluralExpression::InvalidExpression)
    end
  end

  it "keeps the failure class the evaluation raised" do
    FastGettext::PluralExpression::InvalidExpression.ancestors.should include(SyntaxError)
  end
end
