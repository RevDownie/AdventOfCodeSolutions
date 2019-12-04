import math

# Part One - Process list of opcodes. The opcode acts on the subsequent numbers, after each opcode you skip 4.
# 1 => addition
# 2 => Multiplication
# 99 => terminate
#
def part_one(opcodes, noun, verb):

	copy_opcodes = list(opcodes)
	actions = [None] * 100
	actions[1] = lambda a,b: a + b
	actions[2] = lambda a,b: a * b

	# Weirdly the puzzle explicitly states this needs to be done, probably so that the data works for part one and two
	copy_opcodes[1] = noun
	copy_opcodes[2] = verb

	for i in range(0, len(copy_opcodes), 4):
		if copy_opcodes[i] == 99:
			break

		opcode = copy_opcodes[i]
		idx_a = copy_opcodes[i+1]
		idx_b = copy_opcodes[i+2]
		idx_out = copy_opcodes[i+3]
		copy_opcodes[idx_out] = actions[opcode](copy_opcodes[idx_a], copy_opcodes[idx_b])

	return copy_opcodes[0]


# Part Two - Find the noun and verb that produce the output 19690720 at address 0.
# Plotted the 100x100 as a 3D graph to find the relationship between the numbers
# The noun is the main factor and the verb just adds 1 so we can find the closest
# noun on a straight line and add on the remaining verb
#
# Which is better than brute forcing 100x100
#
def part_two(opcodes):

	# Pick 2 points on the line
	r1 = part_one(opcodes, 0, 0)
	r2 = part_one(opcodes, 99, 0)

	# Calculate the X to find our target Y
	m = (r2 - r1)/100
	noun = (19690720/m) - 1

	# Pop that in and see how far off we are and that gives us the y we need
	min_verb = part_one(opcodes, noun, 0)
	verb = 19690720 - min_verb

	return 100 * noun + verb

with open('input.txt') as opcodes:
	as_list = [int(opcode) for opcode in opcodes.read().split(',')]

	print(part_one(as_list, 12, 2))
	print(part_two(as_list))

