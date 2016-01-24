## File for normal stacks. Use for test and experiments.

type NormalStack{T,D}
  # IO
  input::IOStream # Pointer on a file to avoid memory consumption
  output::Nullable{IOStream} # Pointer to an optional (Nullable) output file
  # Functions defining the behavior of the stack in case of push/pop
  push_condition::Function
  push_action::Function
  pop_condition::Function
  pop_action::Function
  # (Explicit) data and context
  data::Vector{D}
  context::Nullable{T}
  index::Int
end

function NormalStack(input::IOStream, context_type::DataType,
  data_type::DataType, push_action::Function, push_condition::Function,
  pop_action::Function, pop_condition::Function;
  index = 0, context = Nullable{context_type}(), output = Nullable{IOStream}())

  data = Vector{data_type}()
  NormalStack(input, output, push_condition, push_action, pop_condition,
  pop_action, data, context, index)
end

function NormalStack(name::AbstractString, pop_action::Function,
  push_action::Function, pop_condition::Function, push_condition::Function,
  context_type::DataType, data_type::DataType)

  input = open(name, "r")
  output_name = name * "_out"
  output = open(output_name, "w")
  settings = get_settings(input)

  NormalStack(input, context_type, data_type, push_action, push_condition, pop_action,
  pop_condition; output= Nullable{IOStream}(output))
end

function top(stack::NormalStack)
  return stack.data[end]
end

function isempty(stack::NormalStack)
  isempty(stack.data)
end

function push!{D}(stack::NormalStack, elt::D)
  push!(stack.data, elt)
  stack.push_action(stack, elt)
end

function pop!(stack::NormalStack)
  elt = pop!(stack.data)
  stack.pop_action(stack, elt)
end

function run!(stack::NormalStack)
  while !eof(stack.input)
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end

function readinput(stack::NormalStack)
  stack.index += 1
  line = readline(stack.input)
  aux = split(line)
  return parse(Int,aux[1])
end
