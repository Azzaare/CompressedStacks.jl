### File with the types for CompressedStacks

## Parametric CompressedStack
type ExtPair{T}
  first::Int
  last::Int
  context::T
end
typealias Block{T} Vector{ExtPair{T}}
typealias Levels{T} Vector{Block{T}}

type CompressedStack{T}
  size::Int
  space::Int
  depth::Int
  input::Nullable{IOStream}
  ouput::Nullable{IOStream}
  condition_push::Function
  action_push::Function
  condition_pop::Function
  action_pop::Function
  f_explicit::Vector{Int}
  f_compressed::Levels{T}
  s_explicit::Vector{Int}
  s_compressed::Levels{T}
  compressed::Nullable{ExtPair{T}}
end

## Fixed types
typealias IntStack CompressedStack{Int}
typealias Float64Stack CompressedStack{Float64}
typealias StringStack CompressedStack{ASCIIString}

## Constructors
function CompressedStack(input_size::Int, space::Int, context_type::DataType,
  condition_push::Function, action_push::Function,
  condition_pop::Function, action_pop::Function,
  input_file = Nullable{IOStream}(), output_file = Nullable{IOStream}())

  h = convert(Int,ceil(log(space,input_size-0.1))) - 1
  compressed = Nullable{ExtPair{context_type}}()
  f_explicit = Vector{Int}()
  f_compressed = Levels{context_type}()
  s_explicit = Vector{Int}()
  s_compressed = Levels{context_type}()

  CompressedStack(input_size, space, h, input_file, output_file,
  condition_push, action_push, condition_pop, action_pop,
  f_explicit, f_compressed, s_explicit, s_compressed, compressed)
end
