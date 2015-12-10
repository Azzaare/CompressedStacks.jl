### File with the types for CompressedStack

## Type Pair
type Pair
  first::Int
  last::Int
end
function Pair(elt::Int)
  Pair(elt,elt)
end

typealias Level Vector{Pair}

## Type CompressedStack
type CompressedStack
  size::Int
  space::Int
  depth::Int
  input::Vector{Bool}
  compressed::Pair
  f_explicit::Vector{Int}
  s_explicit::Vector{Int}
  f_compressed::Vector{Level}
  s_compressed::Vector{Level}
end

# Constructor
function CompressedStack(input_size::Int, space::Int, input::Vector{Bool})
  h = convert(Int,ceil(log(space,input_size-0.1))) - 1
  compressed_tail = Pair(0,0)
  explicit_first = Vector{Int}()
  explicit_second = Vector{Int}()
  compressed_first = Vector{Level}()
  compressed_second = Vector{Level}()
  for i in 1:(h-1)
    push!(compressed_first,Vector{Pair}())
    push!(compressed_second,Vector{Pair}())
  end
  CompressedStack(input_size,space,h,input,compressed_tail, explicit_first,
  explicit_second, compressed_first, compressed_second)
end
