from collections import defaultdict

# Part One - Counting letters in words.
#
# Count the number of words that have exactly 2 of the same letter in them
# Count the number of words that have exactly 3 of the same letter in them
# Multiply the counts together to get the solution
#
# NOTE: If a word has multiple doubles or triples they only count once
#
# Works by sorting the characters in the words and then counting sequentially until letter changes
#
def part_one(words):
	sorted_words = map(sorted, words)
	multiple_counts_per_word = map(count_multiple_in_word, sorted_words)
	multiple_totals = reduce(lambda a, b: (a[0] + b[0], a[1] + b[1]), multiple_counts_per_word)
	return multiple_totals[0] * multiple_totals[1]

# Return the number of doubles and triples in the given SORTED word
# NOTE: As per the rules the number of doubles and triples is clamped to 1
#
def count_multiple_in_word(word):
	two_count = 0
	three_count = 0
	prev_char = 0
	count = 1
	for char in word:
		if char == prev_char:
			count = count + 1
		else:
			if count == 3:
				three_count = 1
			elif count == 2:
				two_count = 1
			prev_char = char
			count = 1

	if count == 3:
		three_count = 1
	elif count == 2:
		two_count = 1

	return (two_count, three_count)

# Given a list of words find the words that differ by only a single letter 
# and return the letters that the two words have in common
#
# Implementation: For each word in turn replace each character with a wildcard and add to the set
# can then just check if the set contains will match if they differ by only 1 character
#
def part_two(words):
	variants = set()
	for word in words:
		chars = list(word)
		for i in range(len(chars)):
			c = chars[i]
			chars[i] = '*'
			variant = "".join(chars)
			if variant in variants:
				return variant.replace('*', '')
			variants.add(variant)
			chars[i] = c

with open('input.txt') as words:
	as_list = [line for line in words]
	print(part_one(as_list))
	print(part_two(as_list))