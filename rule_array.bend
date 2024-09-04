# Data Types
type Bool:
  True
  False

type CellTree:
  Node { rule, value, ~left, ~right }
  Leaf { value }

type Rule:
  AND
  OR
  XOR
  NAND
  NOR
  XNOR
  IMPLICATION
  EQUIVALENCE
  ALWAYS_TRUE
  ALWAYS_FALSE
  A
  B
  NOT_A
  NOT_B

# Rule Application
def apply_rule(rule, a, b):
  match rule:
    case Rule/AND:
      return and(a, b)
    case Rule/OR:
      return or(a, b)
    case Rule/XOR:
      return xor(a, b)
    case Rule/NAND:
      return not(and(a, b))
    case Rule/NOR:
      return not(or(a, b))
    case Rule/XNOR:
      return not(xor(a, b))
    case Rule/IMPLICATION:
      return or(not(a), b)
    case Rule/EQUIVALENCE:
      return and(or(not(a), b), or(a, not(b)))
    case Rule/ALWAYS_TRUE:
      return Bool/True
    case Rule/ALWAYS_FALSE:
      return Bool/False
    case Rule/A:
      return a
    case Rule/B:
      return b
    case Rule/NOT_A:
      return not(a)
    case Rule/NOT_B:
      return not(b)

# Helper Boolean Functions
def and(a, b):
  match a:
    case Bool/True:
      return b
    case Bool/False:
      return Bool/False

def or(a, b):
  match a:
    case Bool/True:
      return Bool/True
    case Bool/False:
      return b

def xor(a, b):
  match a:
    case Bool/True:
      return not(b)
    case Bool/False:
      return b

def not(a):
  match a:
    case Bool/True:
      return Bool/False
    case Bool/False:
      return Bool/True

# Random Number Generation (using xorshift)
def random(seed):
  state = seed ^ (seed << 13)
  state = state ^ (state >> 17)
  state = state ^ (state << 5)
  return state

# Random Rule Generation
def random_rule(seed):
  rand = random(seed) % 14
  switch rand:
    case 0:
      return Rule/AND
    case 1:
      return Rule/OR
    case 2:
      return Rule/XOR
    case 3:
      return Rule/NAND
    case 4:
      return Rule/NOR
    case 5:
      return Rule/XNOR
    case 6:
      return Rule/IMPLICATION
    case 7:
      return Rule/EQUIVALENCE
    case 8:
      return Rule/ALWAYS_TRUE
    case 9:
      return Rule/ALWAYS_FALSE
    case 10:
      return Rule/A
    case 11:
      return Rule/B
    case 12:
      return Rule/NOT_A
    case _:
      return Rule/NOT_B

# Random Boolean Generation
def random_bool(seed):
  if (random(seed) % 2) == 0:
    return Bool/True
  else:
    return Bool/False

# Apparently this isn't part of the standard library?
def String/concat(s1, s2):
  match s1:
    case String/Cons:
      return String/Cons(s1.head, String/concat(s1.tail, s2))
    case String/Nil:
      return s2

# Tree Creation
def create_tree(depth, seed):
  bend depth, seed:
    when depth != 0:
      rule = random_rule(seed)
      value = random_bool(seed + 1)
      left_seed = seed * 2 + 1
      right_seed = seed * 2 + 2
      return CellTree/Node(
        rule,
        value,
        fork(depth - 1, left_seed),
        fork(depth - 1, right_seed)
      )
    else:
      value = random_bool(seed + 1)
      return CellTree/Leaf(value)

def get_value(tree):
  match tree:
    case CellTree/Node:
      return tree.value
    case CellTree/Leaf:
      return tree.value

# Tree Update
def update_tree(tree):
  fold tree:
    case CellTree/Node:
      left_value = get_value(tree.left)
      right_value = get_value(tree.right)
      new_value = apply_rule(tree.rule, left_value, right_value)
      return CellTree/Node { rule: tree.rule, value: new_value, left: tree.left, right: tree.right }
    case CellTree/Leaf:
      return tree


def print_tree(tree):
  return print_tree_helper(tree, 0)

def print_tree_helper(tree, depth):
  indent = String/repeat("  ", depth)
  match tree:
    case CellTree/Node:
      node_str = String/concat(indent, "Node: ")
      node_str = String/concat(node_str, bool_to_string(tree.value))
      node_str = String/concat(node_str, ", ")
      node_str = String/concat(node_str, rule_to_string(tree.rule))
      node_str = String/concat(node_str, "\n")
      left_str = print_tree_helper(tree.left, depth + 1)
      right_str = print_tree_helper(tree.right, depth + 1)
      return String/concat(node_str, String/concat(left_str, right_str))
    case CellTree/Leaf:
      leaf_str = String/concat(indent, "Leaf: ")
      leaf_str = String/concat(leaf_str, bool_to_string(tree.value))
      leaf_str = String/concat(leaf_str, "\n")
      return leaf_str

def String/repeat(str, n):
  bend result = "", count = n:
    when count > 0:
      return fork(String/concat(result, str), count - 1)
    else:
      return result

def bool_to_string(bool):
  match bool:
    case Bool/True:
      return "True"
    case Bool/False:
      return "False"

# Helper function to convert Rule to String
def rule_to_string(rule):
  match rule:
    case Rule/AND:
      return "AND"
    case Rule/OR:
      return "OR"
    case Rule/XOR:
      return "XOR"
    case Rule/NAND:
      return "NAND"
    case Rule/NOR:
      return "NOR"
    case Rule/XNOR:
      return "XNOR"
    case Rule/IMPLICATION:
      return "IMPLICATION"
    case Rule/EQUIVALENCE:
      return "EQUIVALENCE"
    case Rule/ALWAYS_TRUE:
      return "ALWAYS_TRUE"
    case Rule/ALWAYS_FALSE:
      return "ALWAYS_FALSE"
    case Rule/A:
      return "A"
    case Rule/B:
      return "B"
    case Rule/NOT_A:
      return "NOT_A"
    case Rule/NOT_B:
      return "NOT_B"

# Main Function
def main:
  with IO:
    # This comment not accurate:
    # This (depth=3) will create a 7x7 grid (2^3 - 1 = 7)
    # Ideally, we'd specify depth naturally (7 instead of 3), but that would require computing log(base 2)(depth+1), and
    # log is an F24 operation and conversion between number types isn't currently supported, so, we're stuck with this.
    initial_depth = 3
    initial_seed = 12345
    initial_tree = create_tree(initial_depth, initial_seed)
    initial_tree_str = String/concat("\nInitial Tree:\n", print_tree(initial_tree))
    * <- IO/print(initial_tree_str)
    updated_tree = update_tree(initial_tree)
    updated_tree_str = String/concat("\nUpdated Tree:\n", print_tree(updated_tree))
    * <- IO/print(updated_tree_str)
    return *