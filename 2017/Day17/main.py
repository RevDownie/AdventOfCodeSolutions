
# An 'expanding' circular buffer where each iteration the cursor steps round the buffer by the given stride 
# and inserts a value into the next element. Returns the number after the last inserted value
# 
def part_one(step_size, num_spins):
	buffer = [''] * (num_spins + 1)
	current_index = 0

	buffer[0] = 0

	for i in xrange(num_spins):
		step = i + 1
		current_index = ((current_index + step_size) % step) + 1
		insert(buffer, step, current_index, step)

	return buffer[(current_index + 1) % num_spins]

# As part one but returns the number to the right of '0'. Simulating this like part 1 with 50,000,000 iterations was waaay too slow.
# So instead we shortcut. We know that 0 is always at the 0 index because nothing can insert before 0 therefore we only have to
# simulate element 1 which removes all the shunting post insert. Looking at the output from each iteration in part one I'm sure there
# is a mathematical relationship as there is a clear pattern but doing it this way proved quick enough for now
# 
def part_two(step_size, num_spins):
	buffer = [''] * 2 # Only care about element 1
	current_index = 0

	buffer[0] = 0

	for i in xrange(num_spins):
		step = i + 1
		current_index = ((current_index + step_size) % step) + 1
		if current_index < len(buffer):
			buffer[current_index] = step

	return buffer[1]

# Sets the element at the given index to the given value and shuffles all preceding values along
# to make room
# 
def insert(buffer, size, index, val):
	for i in xrange(size, index - 1, -1):
		buffer[i] = buffer[i-1]

	buffer[index] = val
	return buffer

print(part_one(359, 2017))
print(part_two(359, 50000000))
