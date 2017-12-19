import sys

# Given a list of numbers find the max number (first if equal) and divvy out its contents starting at the next
# location and looping until all contents have been distributed. Snapshots the values at that point
# and repeats the process until it comes across a value pattern that has already been seen
# 
def part_one(mem_blocks):
	history = set()
	history.add(pack_blocks(mem_blocks))
	while True:
		index = max_index(mem_blocks)
		num_dist = mem_blocks[index]
		mem_blocks[index] = 0
		while num_dist > 0:
			index = (index + 1) % len(mem_blocks)
			mem_blocks[index] = mem_blocks[index] + 1
			num_dist = num_dist - 1

		packed = pack_blocks(mem_blocks)
		if packed in history:
			break
		history.add(packed)

	return len(history)

# Similar to part one but instead of calculating the total number of steps
# calculates the number of steps since the first occurunce of the duplicate
# 
def part_two(mem_blocks):
	history = list()
	history.append(pack_blocks(mem_blocks))
	while True:
		index = max_index(mem_blocks)
		num_dist = mem_blocks[index]
		mem_blocks[index] = 0
		while num_dist > 0:
			index = (index + 1) % len(mem_blocks)
			mem_blocks[index] = mem_blocks[index] + 1
			num_dist = num_dist - 1

		packed = pack_blocks(mem_blocks)
		found_index = index_of(history, packed)
		if found_index != None:
			return len(history) - found_index
			break
		history.append(packed)

	return None

# Method that returns the index of the max value in the list. 
# If two values are max will return the first one encountered
# 
def max_index(data_set):
	curr_max = -sys.maxsize - 1
	max_index = 0
	for i in xrange(len(data_set)):
		if data_set[i] > curr_max:
			curr_max = data_set[i]
			max_index = i
	return max_index

# Method that converts the blocks of memory into a string that can be hased and stored
# in a set
# 
def pack_blocks(blocks):
	return ' '.join(map(str, blocks))

# Wraps index and turns the error into None
# 
def index_of(data_set, value):
    try:
        return data_set.index(value)
    except ValueError:
        return None

mem_blocks = [4,10,4,1,8,4,9,14,5,1,14,15,0,15,3,5]
print(part_one(list(mem_blocks)))
print(part_two(list(mem_blocks)))