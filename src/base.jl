### Basic types and constructors for CompressedStack ###

## Compressed SubBlocks Signatures
type Signature{T}
  first::Int
  last::Int
  context::T
  pos::Int # position of the input
end

## A Partially Compressed Block is composed of the signatures of its SubBlocks
typealias Block{T} Vector{Signature{T}}
## Each level of compressed Blocks (first and second) are stored in Levels
typealias Levels{T} Vector{Block{T}}
## Type Data to store the data and their index
type Data{D}
  data::D
  index::Int
end

## Constructor for Signature
# Constructor for singleton signature
function Signature{T}(index::Int, context::T, pos::Int)
  Signature(index, index, context, pos)
end
# Constructor for a Signature (from a Block)
function Signature{T}(block::Block{T})
  context = block[1].context
  first = block[1].first
  pos = block[1].pos
  last = block[end].last
  Signature(first, last, context, pos)
end

## General CompressedStack (i.e. with parametric context T and data type D)
# D can also be used as an index when the data type is too big
type CompressedStack{T,D}
  # Structure constraints
  size::Int # Size of the input in #elements
  space::Int # Maximum space order of the compressed stack
  depth::Int # Depth (#levels of compression) based on size and space
  # IO
  input::IOStream # Pointer on a file to avoid memory consumption
  pos::Int # Position of the input before the reading
  output::Nullable{IOStream} # Pointer to an optional (Nullable) output file
  # Functions defining the behavior of the stack in case of push/pop
  push_condition::Function
  push_action::Function
  pop_condition::Function
  pop_action::Function
  # First Blocks
  first_partial::Levels{T} # Levels of partially compressed blocks
  first_explicit::Vector{Data{D}}
  first_sign::Nullable{Signature{T}}
  # Second Blocks
  second_partial::Levels{T} # Levels of partially compressed blocks
  second_explicit::Vector{Data{D}}
  second_sign::Nullable{Signature{T}}
  # Fully Compressed Block (only a signature possibly empty [Nullable])
  compressed::Nullable{Signature{T}}
  # Stack's running information
  index::Int # Stock the maximum index read in the input file
  context::Nullable{T} # Current context to use while making block signatures
  # types
  context_type::DataType
  data_type::DataType
end

# General Constructor for CompressedStack
function CompressedStack(size::Int, space::Int, input::IOStream,
  context_type::DataType, data_type::DataType,
  push_action::Function, push_condition::Function,
  pop_action::Function, pop_condition::Function;
  pos = position(input),
  index = 0, context = Nullable{context_type}(), output = Nullable{IOStream}())

  depth = convert(Int,ceil(log(space, size - 0.1))) - 1
  compressed = Nullable{Signature{context_type}}()
  first_explicit = Vector{Data{data_type}}()
  first_partial = Levels{context_type}()
  second_explicit = Vector{Data{data_type}}()
  second_partial = Levels{context_type}()
  sign_explicit = compressed

  # Initialization of each Block at each level
  for i in 1:(depth-1)
    push!(first_partial,Vector{Signature{context_type}}())
    push!(second_partial,Vector{Signature{context_type}}())
  end

  # Call to the basic constructor
  CompressedStack(size, space, depth, input, pos, output, push_condition,
  push_action, pop_condition, pop_action, first_partial, first_explicit,
  sign_explicit, second_partial, second_explicit, sign_explicit,
  compressed, index, context, context_type, data_type)
end

# Constructor for the reconstruction procedure
function CompressedStack(stack::CompressedStack, size::Int, context, index::Int,
  pos::Int)

  input = stack.input
  seek(input, pos)

  CompressedStack(size * stack.space, stack.space, input, stack.context_type,
  stack.data_type, stack.push_action, stack.push_condition,
  stack.pop_action, stack.pop_condition;
  index = index, context = Nullable(context), output = Nullable{IOStream}())
end

### Constructor for CompressedStack from a file input ##
## No given output file, $(name)_out is generated
# Size and space given in the input file
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

# Size and space given by the user
function CompressedStack(name::AbstractString, pop_action::Function,
  push_action::Function, pop_condition::Function, push_condition::Function,
  context_type::DataType, data_type::DataType, size::Int, space::Int)

  input = open(name, "r")
  output_name = name * "_out"
  output = open(output_name, "w")
  settings = get_settings(input)

  CompressedStack(size, space, input, context_type, data_type,
  push_action, push_condition, pop_action, pop_condition;
  output= Nullable{IOStream}(output))
end
