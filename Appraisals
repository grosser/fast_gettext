['2.3', '3.2', '4.0'].each do |version|
  appraise "rails#{version.sub(".", "")}" do
    gem "rails", "~>#{version}.0"
    if version > "4"
      gem "protected_attributes"
    end
  end
end
