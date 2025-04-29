# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutRegularExpressions < Neo::Koan
  def test_a_pattern_is_a_regular_expression
    # In Ruby, all regular expressions are objects of the Regexp class.
    assert_equal Regexp, /pattern/.class
  end

  def test_a_regexp_can_search_a_string_for_matching_content
    # The [] method returns the portion of the string that matches.
    assert_equal "match", "some matching content"[/match/]
  end

  def test_a_failed_match_returns_nil
    # If there is no match, the [] method returns nil.
    assert_equal nil, "some matching content"[/missing/]
  end

  # ------------------------------------------------------------------

  def test_question_mark_means_optional
    # ? makes the preceding character optional.
    assert_equal "ab", "abbcccddddeeeee"[/ab?/]
    assert_equal "a", "abbcccddddeeeee"[/az?/]
  end

  def test_plus_means_one_or_more
    # + requires one or more of the preceding element.
    assert_equal "bccc", "abbcccddddeeeee"[/bc+/]
  end

  def test_asterisk_means_zero_or_more
    # * permits the preceding element to occur zero or more times.
    assert_equal "abb", "abbcccddddeeeee"[/ab*/]
    assert_equal "a", "abbcccddddeeeee"[/az*/]
    # When no "z" is found, it matches zero occurrences, returning an empty string.
    assert_equal "", "abbcccddddeeeee"[/z*/]
  end

  # ------------------------------------------------------------------

  def test_the_left_most_match_wins
    # The engine selects the left-most match in the string.
    assert_equal "a", "abbccc az"[/az*/]
  end

  # ------------------------------------------------------------------

  def test_character_classes_give_options_for_a_character
    animals = ["cat", "bat", "rat", "zat"]
    # Only animals starting with c, b, or r followed by "at" are matched.
    assert_equal ["cat", "bat", "rat"], animals.select { |a| a[/[cbr]at/] }
  end

  def test_slash_d_is_a_shortcut_for_a_digit_character_class
    # [0123456789]+ is equivalent to \d+ (matches one or more digits)
    assert_equal "42", "the number is 42"[/[0123456789]+/]
    assert_equal "42", "the number is 42"[/\d+/]
  end

  def test_character_classes_can_include_ranges
    # A range can be used to specify character classes. [0-9]+ matches one or more digits.
    assert_equal "42", "the number is 42"[/[0-9]+/]
  end

  def test_slash_s_is_a_shortcut_for_a_whitespace_character_class
    # \s+ matches one or more whitespace characters.
    assert_equal " \t\n", "space: \t\n"[/\s+/]
  end

  def test_slash_w_is_a_shortcut_for_a_word_character_class
    # Both patterns match the word before the equals sign.
    assert_equal "variable_1", "variable_1 = 42"[/[a-zA-Z0-9_]+/]
    assert_equal "variable_1", "variable_1 = 42"[/\w+/]
  end

  def test_period_is_a_shortcut_for_any_non_newline_character
    # The dot (.) matches any character except newline.
    # In "abc\n123", the .+ matches "abc" and stops at the newline.
    assert_equal "abc", "abc\n123"[/a.+/]
  end

  def test_a_character_class_can_be_negated
    # [^0-9]+ matches one or more characters that are NOT digits.
    assert_equal "the number is ", "the number is 42"[/[^0-9]+/]
  end

  def test_shortcut_character_classes_are_negated_with_capitals
    # \D+ matches one or more non-digit characters.
    assert_equal "the number is ", "the number is 42"[/\D+/]
    # \S+ matches one or more non-whitespace characters.
    assert_equal "space:", "space: \t\n"[/\S+/]
    # [^a-zA-Z0-9_]+ matches one or more characters that are NOT word characters.
    assert_equal " = ", "variable_1 = 42"[/[^a-zA-Z0-9_]+/]
    # \W+ is equivalent to [^a-zA-Z0-9_]+.
    assert_equal " = ", "variable_1 = 42"[/\W+/]
  end

  # ------------------------------------------------------------------

  def test_slash_a_anchors_to_the_start_of_the_string
    # \A matches the beginning of the string.
    assert_equal "start", "start end"[/\Astart/]
    # "end" does not occur at the beginning, so returns nil.
    assert_equal nil, "start end"[/\Aend/]
  end

  def test_slash_z_anchors_to_the_end_of_the_string
    # \z matches the very end of the string.
    assert_equal "end", "start end"[/end\z/]
    # "start" is not at the very end, so returns nil.
    assert_equal nil, "start end"[/start\z/]
  end

  def test_caret_anchors_to_the_start_of_lines
    # ^ matches the start of a line (not just the beginning of the string).
    # In this multi-line string, it will match the beginning of the second line.
    assert_equal "2", "num 42\n2 lines"[/^\d+/]
  end

  def test_dollar_sign_anchors_to_the_end_of_lines
    # $ matches the end of a line.
    assert_equal "42", "2 lines\nnum 42"[/\d+$/]
  end

  def test_slash_b_anchors_to_a_word_boundary
    # \b ensures the match occurs at a word boundary.
    assert_equal "vines", "bovine vines"[/\bvine./]
  end

  # ------------------------------------------------------------------

  def test_parentheses_group_contents
    # The parentheses group "ha" one or more times.
    # "ahahaha" has "ha" repeated three times, matching "hahaha".
    assert_equal "hahaha", "ahahaha"[/(ha)+/]
  end

  # ------------------------------------------------------------------

  def test_parentheses_also_capture_matched_content_by_number
    # Capture groups are numbered from 1.
    assert_equal "Gray", "Gray, James"[/(\w+), (\w+)/, 1]
    assert_equal "James", "Gray, James"[/(\w+), (\w+)/, 2]
  end

  def test_variables_can_also_be_used_to_access_captures
    # When the overall pattern is matched, $1 and $2 are set.
    assert_equal "Gray, James", "Name:  Gray, James"[/(\w+), (\w+)/]
    assert_equal "Gray", $1
    assert_equal "James", $2
  end

  # ------------------------------------------------------------------

  def test_a_vertical_pipe_means_or
    grays = /(James|Dana|Summer) Gray/
    # Full match:
    assert_equal "James Gray", "James Gray"[grays]
    # With capture group:
    assert_equal "Summer", "Summer Gray"[grays, 1]
    # "Jim" is not one of the alternatives.
    assert_equal nil, "Jim Gray"[grays, 1]
  end

  # THINK ABOUT IT:
  # A character class ([...]) sets a range of characters to match a single position,
  # whereas alternation (|) allows for matching one of multiple longer expressions.

  # ------------------------------------------------------------------

  def test_scan_is_like_find_all
    # scan returns an array of all substrings that match the regex.
    assert_equal ["one", "two", "three"], "one two-three".scan(/\w+/)
  end

  def test_sub_is_like_find_and_replace
    # sub replaces the first occurrence that matches.
    # It replaces "two" with its first character "t".
    assert_equal "one t-three", "one two-three".sub(/(t\w*)/) { $1[0, 1] }
  end

  def test_gsub_is_like_find_and_replace_all
    # gsub replaces all occurrences.
    # Both "two" and "three" are replaced by "t".
    assert_equal "one t-t", "one two-three".gsub(/(t\w*)/) { $1[0, 1] }
  end
end
