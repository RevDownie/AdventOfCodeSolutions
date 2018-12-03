# Part One - Simple addition puzzle, reading a bunch of integer input
# and keeping track of the count
#
def part_one(frequencies):
	return sum(frequencies)

# Part Two - Loop through doing addition until the same number if reached twice. 
# Returns the first number reached twice.
# NOTE: May need to loop multiple times
#
def part_two(frequencies):
	seen_totals = set()
	total = 0
	counter = 0

	#Starting value has been seen
	seen_totals.add(total)

	while True:
		total += frequencies[counter % len(as_list)]
		if total in seen_totals:
			return total
		seen_totals.add(total)
		counter = counter + 1

with open('input.txt') as frequencies:
	as_list = [int(line) for line in frequencies]

	print(part_one(as_list))
	print(part_two(as_list))