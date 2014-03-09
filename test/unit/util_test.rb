require 'test_helper'

# ruby -I test test/unit/util_test.rb
class UtilTest < ActiveSupport::TestCase
  
  NEW_SPACE_TOKEN = 'check&nbsp;this'
  AMPERSAND_TOKEN = 'helper&amp;tools'
  LESS_THEN_TOKEN = '5&lt;6'
  GREATER_THEN_TOKEN = '&gt;Big'
  QUOTATION_TOKEN = 'the &quot;Tutorial'
  
  test "contains_escaped_html_sequence" do
    found_token = Util.contains_escaped_html_sequence?(NEW_SPACE_TOKEN)
    assert found_token != nil, "The found token was nil"
    assert found_token == EscapedCharacters::SPACE, "The found token was: #{found_token}, but should have been: #{EscapedCharacters::SPACE}"
    
    found_token = Util.contains_escaped_html_sequence?(AMPERSAND_TOKEN)
    assert found_token != nil, "The found token was nil"
    assert found_token == EscapedCharacters::AMPERSAND, "The found token was: #{found_token}, but should have been: #{EscapedCharacters::AMPERSAND}"
    
    found_token = Util.contains_escaped_html_sequence?(LESS_THEN_TOKEN)
    assert found_token != nil, "The found token was nil"
    assert found_token == EscapedCharacters::LESS_THEN, "The found token was: #{found_token}, but should have been: #{EscapedCharacters::LESS_THEN}"
    
    found_token = Util.contains_escaped_html_sequence?(GREATER_THEN_TOKEN)
    assert found_token != nil, "The found token was nil"
    assert found_token == EscapedCharacters::GREATER_THEN, "The found token was: #{found_token}, but should have been: #{EscapedCharacters::GREATER_THEN}"
    
    found_token = Util.contains_escaped_html_sequence?(QUOTATION_TOKEN)
    assert found_token != nil, "The found token was nil"
    assert found_token == EscapedCharacters::QUOTATION, "The found token was: #{found_token}, but should have been: #{EscapedCharacters::QUOTATION}"
  end
end
