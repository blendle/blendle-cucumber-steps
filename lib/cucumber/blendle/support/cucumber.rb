Before do |scenario|
  @scenario_name = scenario.name
  @scenario_hash = Digest::SHA1.hexdigest(@scenario_name)[5]
  @scenario_tags = scenario.source_tag_names
end

After do
  instance_variable_set(:@scenario_name, nil)
  instance_variable_set(:@scenario_hash, nil)
  instance_variable_set(:@scenario_tags, nil)
end
