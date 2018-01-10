# Advancing left to right (1 move each tick) across a grid where each column has a different number of rows and a scanner that ping-pongs up and down the elements of the row. Calculates
# a score for every time the scanner and the player occupy the same cell based on the column index and number of rows. Player only moves across the first row
# 
def part_one(ranges, total_timesteps):
	current_score = 0

	# Timestep also acts as location of the packet as it moves one space every step
	for timestep in xrange(total_timesteps):
		try:
			r = ranges[timestep]
			scanner_pos = sample_tri_wave(timestep, r - 1)

			# The packet only moves along the top row (0)
			if scanner_pos == 0:
				current_score += timestep * r
		except KeyError:
			# Some columns have no scanner range
			None

	return current_score

# Part two involes calculating the initial delay to apply to the packet so that it can make it safely across the grid
# without intersecting with the scanner. Returns the delay (technically in picoseconds but essentially just ticks).
# 
# Brute force method - justs runs the simulation for every possible delay until we succeed
# 
def part_two(ranges, total_timesteps):
	current_score = 0
	init_delay = 0
	success = False

	while success == False:
		# This time location is not the same as timestep as we delay movement
		for x in xrange(total_timesteps):
			# Assume we make it through successfully until we don't
			success = True

			try:
				r = ranges[x]
				timestep = init_delay + x
				scanner_pos = sample_tri_wave(timestep, r - 1)

				# The packet only moves along the top row (0). If we collide then this delay is not feasible
				if scanner_pos == 0:
					init_delay += 1
					success = False
					break

			except KeyError:
				# Some columns have no scanner range
				None

	return init_delay

# The ping-pong motion of the scanner up and down the range creates a triangle wave graph that we can use to determine the 
# position of the scanner at any timestep. The amplitude is the scan range and x is the timestamp
# 
def sample_tri_wave(x, amp):
	return amp - abs((x % (amp * 2)) - amp)

# Read the ranges
ranges = {}
total_timesteps = 0

with open("input.txt") as data_file:
	for line in data_file:
		split = line.rstrip().split(' ')

		# Ditch the colon
		split[0] = split[0].rstrip(':')

		r = int(split[0])
		ranges[r] = int(split[1])
		total_timesteps = max(total_timesteps, r)
total_timesteps += 1


print(part_one(ranges, total_timesteps))
print(part_two(ranges, total_timesteps))


