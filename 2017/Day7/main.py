from collections import defaultdict

# Given data describing a tree structure as a list of nodes and children. This function identifies the root node
# Essentially it makes lists of all nodes that have a parent and finds the difference with the list of all nodes
# 
def part_one():
	nodes = set()
	children = set()

	with open("input.txt") as data_file:
		for line in data_file:
			split = line.rstrip().split(' ')
			# Add to the list of nodes so we can compare against those that have parents
			nodes.add(split[0])
			# Only add to the list if the node has child info. The first child starts at index 3
			for i in range(3, len(split)):
				children.add(split[i].rstrip(','))

	return next(iter(nodes - children))

# Given data describing a tree structure as a list of nodes, weight and children. This function builds the tree
# and identifies the node that is unbalancing the weight (the rule is all child sub-trees must have equal weight). 
# Essentially we recurse depth-first through the tree finding the unbalanced branch and then finding the node
# whose children are all balanced
# 
# NOTE: Only one node is imbalanced
# 
def part_two(root):
	adjacencies = defaultdict(list)
	weights = dict()

	with open("input.txt") as data_file:
		for line in data_file:
			split = line.rstrip().split(' ')
			# Store the weight (at index 1) (ignoring the brackets)
			weights[split[0]] = int(split[1][1:-1])
			# The first child starts at index 3
			for i in range(3, len(split)):
				adjacencies[split[0]].append(split[i].rstrip(','))

	return find_corrected_balance(adjacencies, weights, root, None)

# Recursive function that takes the weights and adjacency lists and calculates the total weight
# resting on the given node
# 
def calculate_weight(adjacencies, weights, node_id, total_weight):
	children = adjacencies[node_id]
	total_weight += weights[node_id]
	for child in children:
		total_weight = calculate_weight(adjacencies, weights, child, total_weight)

	return total_weight

# Find the index of the item in the given list that is not the same as the others. 
# Returns None if all the same.
# 
def index_of_different(values):
	num_vals = len(values)
	for i in xrange(num_vals):
		matches = False
		for j in xrange(num_vals-1):
			if values[i] == values[(i + j + 1) % num_vals]:
				matches = True
				break

		if matches == False:
			return i

	return None

# Depth first through the tree, finding the node that is imbalanced and returning
# the value that it should be (based on its siblings)
# 
def find_corrected_balance(adjacencies, weights, node_id, parent_node_id):
	children = adjacencies[node_id]
	child_total_weights = map(lambda c: calculate_weight(adjacencies, weights, c, 0), children)
	diff_index = index_of_different(child_total_weights)

	if diff_index == None:
		# All the children of this node are balanced so the node itself is unbalanced
		siblings = adjacencies[parent_node_id]
		siblings.remove(node_id)
		sibling_weight = calculate_weight(adjacencies, weights, siblings[0], 0)
		node_weight = sum(child_total_weights) + weights[node_id]
		return weights[node_id] + (sibling_weight - node_weight)

	# Go down the tree
	return find_corrected_balance(adjacencies, weights, children[diff_index], node_id)

root = part_one()
print(root)
print(part_two(root))
