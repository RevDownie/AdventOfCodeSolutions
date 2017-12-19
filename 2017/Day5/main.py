
# A list of "instructions" which tell the program counter where to jump. The function must 
# step through all the instructions (jumping around) until it goes beyond the bounds of the instructions
# Everytime an instruction is executed the jump num of that instruction is increased
# The function returns the number of steps required to finish 
# 
def part_one(instructions):
	instruction_index = 0
	num_steps = 0
	while instruction_index < len(instructions):
		jump = instructions[instruction_index]
		instructions[instruction_index] = instructions[instruction_index] + 1
		instruction_index = instruction_index + jump
		num_steps = num_steps + 1

	return num_steps

# As part one but instead of incrementing the jump num by 1 if the jump num is >= 3 the 
# jump num is decremented by 1
# 
def part_two(instructions):
	instruction_index = 0
	num_steps = 0
	while instruction_index < len(instructions):
		jump = instructions[instruction_index]
		instructions[instruction_index] = instructions[instruction_index] + (-1 if jump >= 3 else 1)
		instruction_index = instruction_index + jump
		num_steps = num_steps + 1

	return num_steps

instructions_file = open("input.txt", 'r')
instructions = instructions_file.read().splitlines()
as_nums = map(int, instructions)

print(part_one(list(as_nums)))
print(part_two(list(as_nums)))
