# Part One - Simple calculation puzzle - Determine the fuel required for the given masses
# Divide by 3, round down, minus 2, sum
#
def part_one(masses):
	return sum(map(lambda m: int(m/3) - 2, masses))

# Part Two - The fule also requires fuel as the fuel has mass
# Recursive behaviour adding fuel for the fuel until the mass of the fuel added is small enough to require no fuel
#
def part_two(masses):
	fuel_for_masses = map(lambda m: int(m/3) - 2, masses)

	total_fuel = 0
	for fuel in fuel_for_masses:
		total_fuel += fuel
		while fuel > 0:
			fuel = int(fuel/3) - 2
			total_fuel += max(fuel, 0)

	return total_fuel

with open('input.txt') as masses:
	as_list = [int(line) for line in masses]

	print(part_one(as_list))
	print(part_two(as_list))