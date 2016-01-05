### I/O functions for the CompressedStack structure

## Import in CompressedStacks.jl
# import Base.print, Base.string

## Convert functions : string ##

# Access and convert to Sting the content of a Nullable object
function string{T}(elt::Nullable{T})
  if !isnull(elt)
    str = string(get(elt))
  else
    str = "∅"
  end
  return str
end

# Convert a Signature into a string
function string{T}(sign::Signature{T})
  return "($(sign.first),$(sign.last)) ← $(sign.context)"
end

function string{T}(block::Block{T})
  str = "["
  for (id,sign) in enumerate(block)
    if id == 1
      str *= "$(string(sign))"
    else
      str *= ",$(string(sign))"
    end
  end
  str *= "]"
  return str
end

# Convert a vector of partially compressed blocks into a string
function string{T}(lvl::Levels{T})
  str = "[\t\t\t\t"
  for (id,block) in enumerate(lvl)
      str *= "\n\t\t\tLevel $id\t\t$(string(block))"
  end
  str *= "\n\t\t\t ]"
  return str
end

# Convert a vector of explicit integral values into a string
function string(explicit::Vector{Int})
  str = "["
  for (id,p) in enumerate(explicit)
    if id == 1
      str *= "$p"
    else
      str *= ",$p"
    end
  end
  str *= "]"
  return str
end

## Print functions ##

# Print a CompressedStack in the console
function print(stack::CompressedStack)
  println("Compressed Stack with n=$(stack.size), p=$(stack.space),",
    " and h=$(stack.depth)")
  println("\t First:")
  println("\t\t (first) partially compressed ->")
  println("\t\t\t $(string(stack.first_partial))")
  println("\t\t (first) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(string(stack.first_explicit))")
  println("\t Second:")
  println("\t\t (second) partially compressed ->")
  println("\t\t\t $(string(stack.second_partial))")
  println("\t\t (second) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(string(stack.second_explicit))")
  println("\t Compressed tail:")
  println("\t\t\t\t\t$(string(stack.compressed))\n")
  println("\t Context:")
  println("\t\t\t\t\t$(string(stack.context))\n")
end

## Read from input file

# Get the settings (size, space, ...) of the CompressedStack
function get_settings(f::IOStream)
  i = 0
  size = 0
  space = 0

  while i < 2
    line = readline(f)
    if line[1] != '#'
      i += 1
      if i == 1
        aux = split(line)
        size = parse(Int,aux[1])
        space = parse(Int,aux[2])
      end
    end
  end
  return size,space
end

# Get next element (before a push)
function readinput{T,D}(stack::CompressedStack{T,D})
  stack.index += 1
  line = readline(stack.input)
  aux = split(line)
  return parse(Int,aux[1])
end


## Constructor for CompressedStack from a file input ##

# No given output file, $(name)_out is generated
function CompressedStack(name::AbstractString, pop_action::Function,
  push_action::Function, pop_condition::Function, push_condition::Function,
  context_type::DataType, data_type::DataType)

  input = open(name, "r")
  output_name = name * "_out"
  output = open(output_name, "w")
  settings = get_settings(input)

  CompressedStack(settings[1], settings[2], input, context_type, data_type,
  push_action, push_condition, pop_action, pop_condition;
  output= Nullable{IOStream}(output))
end
