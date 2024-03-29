Given /^an xquery module named "([^"]*)":$/ do
	|module_name, module_text|
	rule_provider_session.set_library_module module_name, module_text
end

Given /^an xquery script:$/ do
	|xquery_text|
	@xquery_text = xquery_text
end

Given /^an input document:$/ do
	|input_text|
	@input_text = input_text
end

Then /^the result should be:$/ do
	|result_text|
	@result_text.should == result_text
end

Then /^I should get an error$/ do
	@exception.should_not be_nil
	@exception = nil
end

Before do
	@input_text = "<xml/>"
	@exception = nil
end

When /^I compile the query$/ do

	begin

		@result_text =
			rule_provider_session.compile_xquery \
				@xquery_text,
				"inline.xquery"

		@exception = nil

	rescue => exception
		@exception = exception
		@result_text = nil
	end
end

When /^I run the query$/ do

	require "xml"

	begin

		@result_text =
			rule_provider_session.run_xquery @input_text \
		do
			|name, args|

			case name

			when "get record by id"
				record = XML::Node.new "get-record-by-id"
				args.each do
					|name, value|
					record[name] = value
				end
				[ record.to_s ]

			when "get record by id parts"
				record = XML::Node.new "get-record-by-id-parts"
				record["type"] = args["type"]
				args["id parts"].each do
					|arg_part|
					part = XML::Node.new "part"
					part["value"] = arg_part
					record << part
				end
				[ record.to_s ]

			when "search records"
				record = XML::Node.new "search-records"
				record["type"] = args["type"]
				(args["criteria"] || []).each do
					|key, value|
					criteria_elem = XML::Node.new "criteria"
					criteria_elem["key"] = key
					criteria_elem["value"] = value
					record << criteria_elem
				end
				[ record.to_s ]

			else
				puts "ERROR #{name}"
				[]

			end

		end

		@exception = nil

	rescue => exception

		@exception = exception
		@result_text = nil

	end

end

When /^I compile the query:$/ do
	|xquery_text|
	step "an xquery script:", xquery_text
	step "I compile the query"
end

When /^I run the query against:$/ do
	|input_text|
	step "an input document:", input_text
	step "I run the query"
end

After do
	if @exception
		raise @exception
	end
end
