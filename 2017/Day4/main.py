
# Given a list of pass phrases filter any passphrase in which a word appears more than once
# Return the total number of valid passphrases
# 
def part_one(passphrases):
	# Convert to a set which will remove duplicates and then check if pre and post dupes lists are the same size
	valid = filter(lambda w: len(w) == len(set(w)), passphrases)
	return len(valid)

# Similar to part one except that we now filter out any words that are
# direct anagrams of another word in the passphrase
# 
def part_two(passphrases):
	# Sort the word characters alphabetically that allows us to discard any with the same letters
	alphabetical = [[''.join(sorted(w)) for w in passphrase] for passphrase in passphrases]
	valid = filter(lambda w: len(w) == len(set(w)), alphabetical)
	return len(valid)

passphrases_file = open("input.txt", 'r')
passphrases = passphrases_file.read().splitlines()
as_words = map(lambda d: d.split(' '), passphrases)

print(part_one(as_words))
print(part_two(as_words))
