# Commonly used webrat steps
# http://github.com/brynary/webrat

def escape_text_for_regexp(text)
  text = text.gsub(/£/, "&pound;") # This allows features to express currencies as the user would see them, but the code to compare with the HTML
  text = Regexp.escape(text).gsub(/\\ /, '\s+') # allow any amount of whitespace / newlines because we're looking at HTML
  /#{text}/im  
end

def strip_html_tags_from(html)
  html.gsub(/<[^>]*>/, "")
end

def within_list(css_class)
  css_selector = css_class.gsub(/ /, '.') #stack the css classes for selection
  list = current_dom.at("ol.#{css_selector}") || current_dom.at("ul.#{css_selector}") # Could add an opt param to the method to make this explicit - for now we don't care
  assert_not_nil(list, "Expected to find a ul or li tag matching the css class '#{css_class}'")
  yield list
end

Given /^I am viewing "(.*)"$/ do |path|
  visits(path)
end

When /^I press "(.*)"$/ do |button|
  clicks_button(button)
end

When /^I follow "(.*)"$/ do |link|
  clicks_link(link)
end

When /^I fill in "(.*)" for "(.*)"$/ do |value, field|
  fills_in(field, :with => value)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  fills_in(field, :with => value)
end

When /^I check "(.*)"$/ do |field|
  checks(field)
end

When /^I uncheck "(.*)"$/ do |field|
  unchecks(field)
end

When /^I choose "(.*)"$/ do |field|
  chooses(field)
end

When /^I select "(.*)" from "(.*)"$/ do |value, field| 
  selects(value, :from => field)
end

When /^I (view|go to|visit) "(.*)"$/ do |_, path|
  visits(path)
end

When /^I clear my session$/ do
  cookies.delete("_session_id")
end

Then /^I should see(?: | the text )?"(.*)"$/ do |text| #"
  response.should have_text(escape_text_for_regexp(text))
end

Then /^I should see the text "(.*)" in the "(.*)" section of the page$/ do |expected_text, container_class| #"
  selector = "div.#{container_class}"
  response.should have_tag(selector, :text => escape_text_for_regexp(expected_text))
end

Then /^I should not see(?: | the text )?"(.*)"$/ do |text| #"
  response.should_not have_text(escape_text_for_regexp(text))
end

Then /^I should be (at|on) "(.*)"$/ do |_, path|
  response.should be_success
  response.request.request_uri.should =~ /(#{root_url.chop})?#{path}/
end

Then /^I should be redirected to "(.*)"$/ do |path|
  response.should redirect_to(path)
end

Then /I should see an image$/ do 
  response.should have_tag("img")
end

Then /^I should see the text "(.*)" in the "(.*)" list$/ do |text, css_class| #"
  within_list(css_class) do |list|
    matching_list_items = list.search("li").select{ |li| strip_html_tags_from(li.inner_html) =~ escape_text_for_regexp(text) }
    assert(matching_list_items.length > 0, "Expected to find at least one list item matching #{escape_text_for_regexp(text)} in this HTML fragment:\n#{list.inner_html}")
  end
end

Then /^I should see an image with the alternate text "(.*)" in the "(.*)" list$/ do |text, css_class| #"
  within_list(css_class) do |list|
    matching_tags = list.search("img").select{ |img| img["alt"] = text }
    assert(matching_tags.length > 0, "Expected to find at least one matching image in this HTML fragment:\n#{list.inner_html}")
  end
end
