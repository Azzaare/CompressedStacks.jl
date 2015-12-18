### Basic types and constructors for CompressedStack ###

## Compressed SubBlocks Signatures
type Signature{T}
  first::Int
  last::Int
  context::T
end

# Constructor for singleton signature
function Signature{T}(index::Int, context::T)
  Signature(index, index, context)
end

## A Partially Compressed Block is composed of the signatures of its SubBlocks
typealias Block{T} Vector{Signature{T}}

# Constructor for a Signature (from a Block)
function Signature{T}(block::Block{T})
  context = block[1].context
  first = block[1].first
  last = block[end].last
  Signature(first, last, context)
end

## Each level of compressed Blocks (first and second) are stored in Levels
typealias Levels{T} Vector{Block{T}}

## General CompressedStack (i.e. with parametric context T and data type D)
# D can also be used as an index when the data type is too big
type CompressedStack{T,D}
  # Structure constraints
  size::Int # Size of the input in #elements
  space::Int # Maximum space order of the compressed stack
  depth::Int # Depth (#levels of compression) based on size and space
  # IO
  input::IOStream # Pointer on a file to avoid memory consumption
  output::Nullable{IOStream} # Pointer to an optional (Nullable) output file
  # Functions defining the behavior of the stack
  # Those function should only take a CompressedStack as input
  push_condition::Function
  push_action::Function
  pop_condition::Function
  pop_action::Function
  # First Blocks
  first_partial::Levels{T} # Levels of partially compressed blocks
  first_explicit::Vector{D}
  # Second Blocks
  second_partial::Levels{T} # Levels of partially compressed blocks
  second_explicit::Vector{D}
  # Fully Compressed Block (only a signature possibly empty [Nullable])
  compressed::Nullable{Signature{T}}
  # Stack's running information
  index::Int # Stock the maximum index read in the input file
  context::Nullable{T} # Current context to use while making block signatures
end

# General Constructor for CompressedStack
function CompressedStack(size::Int, space::Int, input::IOStream,
  context_type::DataType, data_type::DataType,
  push_action::Function, push_condition::Function,
  pop_action::Function, pop_condition::Function;
  index = 0, context = Nullable{context_type}(), output = Nullable{IOStream}())

  depth = convert(Int,ceil(log(space, size - 0.1))) - 1
  compressed = Nullable{Signature{context_type}}()
  first_explicit = Vector{data_type}()
  first_partial = Levels{context_type}()
  second_explicit = Vector{data_type}()
  second_partial = Levels{context_type}()

  # Initialization of each Block at each level
  for i in 1:(depth-1)
    push!(first_partial,Vector{Signature{context_type}}())
    push!(second_partial,Vector{Signature{context_type}}())
  end

  # Call to the basic constructor
  CompressedStack(size, space, depth, input, output, push_condition,
  push_action, pop_condition, pop_action, first_partial, first_explicit,
  second_partial, second_explicit, compressed, index, context)
end