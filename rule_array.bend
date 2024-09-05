# Data Types
type Bool:
  True
  False

type Cell:
  Node { rule, value }
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

def create_grid(width, height, seed):
  bend y = 0, grid = []:
    when y < height:
      new_row = create_row(y, width, seed)
      return fork(y + 1, List/concat(grid, [new_row]))
    else:
      return grid

def create_row(y, width, seed):
  bend x = 0, row = []:
    when x < width:
      if y == 0 | (y % 2 == 1 & x == 0) | (y % 2 == 0 & x == width - 1):
        cell = Cell/Leaf(random_bool(seed + x + y * width))
      else:
        rule = random_rule(seed + x + y * width)
        value = random_bool(seed + x + y * width + 1)
        cell = Cell/Node(rule, value)
      return fork(x + 1, List/concat(row, [cell]))
    else:
      return row

type CellDebug:
  Debug { cell_index, cell_type, rule, old_value, new_value }

def update_grid(grid):
  bend y = 1, updated_grid = [List/index(grid, 0)], debug_info = []:
    when y < get_list_length(grid):
      current_row = List/index(grid, y)
      prev_row = List/index(grid, y - 1)
      (updated_row, row_debug) = update_row(current_row, prev_row, y)
      debug_info = List/concat(debug_info, [row_debug])
      updated_grid = List/concat(updated_grid, [updated_row])
      return fork(y + 1, updated_grid, debug_info)
    else:
      return (updated_grid, debug_info)

def update_row(current_row, prev_row, y):
  bend x = 0, updated_row = [], row_debug = []:
    when x < get_list_length(current_row):
      cell = List/index(current_row, x)
      (updated_cell, cell_debug) = update_cell(cell, x, prev_row)
      row_debug = List/concat(row_debug, [cell_debug])
      updated_row = List/concat(updated_row, [updated_cell])
      return fork(x + 1, updated_row, row_debug)
    else:
      return (updated_row, row_debug)


def update_cell(cell, x, prev_row):
  debug_info = []
  debug_info = List/concat(debug_info, [String/concat("Cell ", int_to_string(x))])
  match cell:
    case Cell/Node:
      debug_info = List/concat(debug_info, ["(Node)"])
      left_index = x
      right_index = x
      if x % 2 == 0:
        left_index = x - 1
        right_index = x
      else:
        left_index = x
        right_index = x + 1

      left_value = Bool/False
      right_value = Bool/False

      if left_index >= 0:
        left_value = get_value(List/index(prev_row, left_index))
      else:
        left_value = left_value

      if right_index < get_list_length(prev_row):
        right_value = get_value(List/index(prev_row, right_index))
      else:
        right_value = right_value

      new_value = apply_rule(cell.rule, left_value, right_value)
      debug_info = List/concat(debug_info, [String/concat("Rule: ", rule_to_string(cell.rule))])
      debug_info = List/concat(debug_info, [String/concat("Old: ", bool_to_string(cell.value))])
      debug_info = List/concat(debug_info, [String/concat("New: ", bool_to_string(new_value))])
      updated_cell = Cell/Node(cell.rule, new_value)
      return (updated_cell, debug_info)
    case Cell/Leaf:
      debug_info = List/concat(debug_info, ["(Leaf)"])
      debug_info = List/concat(debug_info, [String/concat("Value: ", bool_to_string(cell.value))])
      updated_cell = cell
      return (updated_cell, debug_info)

def get_value(cell):
  match cell:
    case Cell/Node:
      return cell.value
    case Cell/Leaf:
      return cell.value

def print_grid(grid):
  bend y = 0, output = "":
    when y < get_list_length(grid):
      row = List/index(grid, y)
      row_str = print_row(row, y)
      output = String/concat(output, row_str)
      return fork(y + 1, output)
    else:
      return output

def print_row(row, y):
  if y % 2 == 0:
    indent = " "
  else:
    indent = ""
  bend x = 0, output = indent:
    when x < get_list_length(row):
      cell = List/index(row, x)
      cell_str = print_cell(cell)
      output = String/concat(output, cell_str)
      return fork(x + 1, output)
    else:
      return String/concat(output, "\n")

def print_cell(cell):
  match cell:
    case Cell/Node:
      char_code = rule_to_char(cell.rule)
      if bool_to_int(cell.value):
        return char_to_string(char_code)
      else:
        return char_to_string(char_code + 32)  # Convert to lowercase
    case Cell/Leaf:
      if bool_to_int(cell.value):
        return "L"
      else:
        return "l"

def rule_to_char(rule):
  match rule:
    case Rule/AND:
      return 65  # 'A'
    case Rule/OR:
      return 79  # 'O'
    case Rule/XOR:
      return 88  # 'X'
    case Rule/NAND:
      return 78  # 'N'
    case Rule/NOR:
      return 82  # 'R'
    case Rule/XNOR:
      return 81  # 'Q'
    case Rule/IMPLICATION:
      return 73  # 'I'
    case Rule/EQUIVALENCE:
      return 69  # 'E'
    case Rule/ALWAYS_TRUE:
      return 84  # 'T'
    case Rule/ALWAYS_FALSE:
      return 70  # 'F'
    case Rule/A:
      return 85  # 'U'
    case Rule/B:
      return 86  # 'V'
    case Rule/NOT_A:
      return 87  # 'W'
    case Rule/NOT_B:
      return 89  # 'Y'

# Apparently this isn't part of the standard library?
def String/concat(s1, s2):
  match s1:
    case String/Cons:
      return String/Cons(s1.head, String/concat(s1.tail, s2))
    case String/Nil:
      return s2

def String/repeat(str, n):
  bend result = "", count = n:
    when count > 0:
      return fork(String/concat(result, str), count - 1)
    else:
      return result


def String/length(s):
  match s:
    case String/Cons:
      return 1 + String/length(s.tail)
    case String/Nil:
      return 0

List/index = @l @i
  match l {
    List/Cons:
      switch i {
        0: l.head
        _: (List/index l.tail (i-1))
      }
    List/Nil: *
  }

def get_list_length(list):
  (len, *) = List/length(list)
  return len

def bool_to_string(bool):
  match bool:
    case Bool/True:
      return "True"
    case Bool/False:
      return "False"

def bool_to_int(bool):
  match bool:
    case Bool/True:
      return 1
    case Bool/False:
      return 0

def int_to_string(n):
  if n < 0:
    return String/concat("-", int_to_string(-1 * n))
  else:
    if n == 0:
      return "0"
    else:
      return String/concat(int_to_string(n / 10), char_to_string(n % 10 + 48))

def char_to_string(c):
  return String/Cons(c, String/Nil)

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


def print_legend:
  legend = "Legend:\n"
  legend = String/concat(legend, "A/a: AND, O/o: OR, X/x: XOR, N/n: NAND\n")
  legend = String/concat(legend, "R/r: NOR, Q/q: XNOR, I/i: IMPLICATION, E/e: EQUIVALENCE\n")
  legend = String/concat(legend, "T/t: ALWAYS_TRUE, F/f: ALWAYS_FALSE\n")
  legend = String/concat(legend, "U/u: A, V/v: B, W/w: NOT_A, Y/y: NOT_B\n")
  legend = String/concat(legend, "L/l: Leaf (True/False)\n")
  legend = String/concat(legend, "Uppercase: True, Lowercase: False\n\n")
  return legend

def main:
  with IO:
    width = 8
    height = 6
    initial_seed = 12345
    initial_grid = create_grid(width, height, initial_seed)
    * <- IO/print(print_legend)
    * <- IO/print(String/concat("Grid dimensions: ", int_to_string(height)))
    * <- IO/print(String/concat("x", int_to_string(width)))
    * <- IO/print("\nInitial Grid:\n")
    * <- IO/print(print_grid(initial_grid))
    * <- IO/print("\nUpdating Grid:\n")
    (updated_grid, debug_info) = update_grid(initial_grid)
    * <- IO/print(print_debug_info(debug_info))
    * <- IO/print("\nFinal Updated Grid:\n")
    * <- IO/print(print_grid(updated_grid))
    return *

def print_debug_info(debug_info):
  bend y = 0, output = "":
    when y < get_list_length(debug_info):
      row_debug = List/index(debug_info, y)
      output = String/concat(output, String/concat("Row ", int_to_string(y+1)))
      output = String/concat(output, ":\n")
      output = String/concat(output, print_row_debug(row_debug))
      return fork(y + 1, output)
    else:
      return output

def print_row_debug(row_debug):
  bend x = 0, output = "":
    when x < get_list_length(row_debug):
      cell_debug = List/index(row_debug, x)
      output = String/concat(output, print_cell_debug(cell_debug))
      return fork(x + 1, output)
    else:
      return String/concat(output, "\n")

def print_cell_debug(cell_debug):
  bend i = 0, output = "":
    when i < get_list_length(cell_debug):
      info = List/index(cell_debug, i)
      output = String/concat(output, info)
      output = String/concat(output, " ")
      return fork(i + 1, output)
    else:
      return String/concat(output, "| ")