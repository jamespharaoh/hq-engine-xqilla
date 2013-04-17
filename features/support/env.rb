require "yaml"

def rule_provider

	return @rule_provider \
		if @rule_provider

	require "hq/engine/subprocess-rule-provider/start"

	spec =
		Gem::Specification.find_by_name \
			"hq-engine-xqilla"

	rule_provider_path =
		"#{spec.gem_dir}/src/xquery-server"

	@rule_provider =
		HQ::Engine::SubProcessRuleProvider.start  \
			rule_provider_path

	return @rule_provider

end

After do
	@rule_provider.close if @rule_provider
end

def rule_provider_session

	return @rule_provider_session ||=
		rule_provider.session

end
