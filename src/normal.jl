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
  data::Vector{Data{D}} # Data type is in base.jl
  context::Nullable{T}
  index::Int
end

function NormalStack(input::IOStream, context_type::DataType,
  data_type::DataType, push_action::Function, push_condition::Function,
  pop_action::Function, pop_condition::Function;
  index = 0, context = Nullable{context_type}(), output = Nullable{IOStream}())

  data = Vector{Data{data_type}}()
  NormalStack(input, output, push_condition, push_action, pop_condition,
  pop_action, data, context, index)
end

## Normal Stack from input file
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
