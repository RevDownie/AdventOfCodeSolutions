from collections import defaultdict

# Each line in the file is an instruction consisting of either an increment ir decrement of a register based on a condition.
# The format of the instructions are "<reg> <inc/dec> <val> if <reg> < >/</>=/<=/!=/== > <val>"
# All registers are initialised to zero and are integers. All instructions are executed and then the largest
# value in any register is returned to solve the puzzle.
# 
def part_one():
	registers = defaultdict(int)

	with open("input.txt") as data_file:
		for line in data_file:
			split = line.rstrip().split(' ')

			# Check the conditional 
			if is_condition_met(split, registers):
				# Update the register value
				new_val = calculate_reg_value(split, registers)
				registers[split[0]] = new_val

	return max(registers.values())

# Similar to part one but instead of returning the highest register value at the end of all the instructions it tracks the peak value at any point during execution
# 
def part_two():
	registers = defaultdict(int)
	reg_peaks = defaultdict(int)

	with open("input.txt") as data_file:
		for line in data_file:
			split = line.rstrip().split(' ')

			# Check the conditional 
			if is_condition_met(split, registers):
				# Update the register value
				new_val = calculate_reg_value(split, registers)
				if new_val > reg_peaks[split[0]]:
					reg_peaks[split[0]] = new_val
				registers[split[0]] = new_val

	return max(reg_peaks.values())

# Given the full instruction split into keywords, this function will return the result of the conditional statement
# 
def is_condition_met(split, registers):
	operator = split[5]
	comparison = int(split[6])
	register = registers[split[4]]

	if operator == '>':
		return register > comparison

	if operator == '<':
		return register < comparison

	if operator == '>=':
		return register >= comparison

	if operator == '<=':
		return register <= comparison

	if operator == '==':
		return register == comparison

	if operator == '!=':
		return register != comparison

	print("Error: Unknown Op " + operator)
	return False

# Given the full instruction split into keywords, this function assumes the condition is true and calculates
# the result of the inc/dec
# 
def calculate_reg_value(split, registers):
	register = registers[split[0]]
	operator = split[1]
	value = int(split[2])

	if operator == 'inc':
		return register + value

	if operator == 'dec':
		return register - value

	return register

print(part_one())
print(part_two())