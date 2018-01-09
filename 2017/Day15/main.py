
# Two generators A and B (seeded with the given numbers) generate numbers using the previously generated number and a distinct
# factor per generator.
# Each time the least significant 16-bits of the 2 generated numbers match we add 1 to the count. We run the generators the given
# number of times are return the number of "matches".
# 
def part_one(seed_a, seed_b, num_generations):
	matches = 0
	gen_a = seed_a
	gen_b = seed_b

	mask = 0x0000ffff

	for i in xrange(num_generations):
		gen_a = generate(gen_a, 16807)
		gen_b = generate(gen_b, 48271)

		if gen_a & mask == gen_b & mask:
			matches += 1

	return matches

# Similar to part one, except that the generated values are only compared if they meet certain criteria
# They still need to be paired so easiest way is to wait for an acceptable generation before allowing the
# other generator to proceed
# 
def part_two(seed_a, seed_b, num_generations):
	matches = 0
	gen_a = seed_a
	gen_b = seed_b

	mask = 0x0000ffff

	for i in xrange(num_generations):
		gen_a = generate_conditional(gen_a, 16807, 4)
		gen_b = generate_conditional(gen_b, 48271, 8)

		if gen_a & mask == gen_b & mask:
			matches += 1

	return matches

# Generation algorithm using the previously generated value (or seed if none)
# 
def generate(prev, factor):
	return (prev * factor) % 2147483647

# Generation algorithm using the previously generated value (or seed if none). Will
# keep generating until the generated value divides evenly by the div_condition
# 
def generate_conditional(prev, factor, div_condition):
	gen = generate(prev, factor)

	while gen % div_condition != 0:
		gen = generate(gen, factor)

	return gen

print(part_one(634, 301, 40000000))
print(part_two(634, 301, 5000000))