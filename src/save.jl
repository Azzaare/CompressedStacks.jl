module CompressedStacks
import Base.print, Base.zero


type Element{T}
  index::Int
  context::T
end

type Pair{T}
  first::Element{T}
  last::Element{T}
end

type CompressedStack{T}
  compressed::Vector{Pair{T}}
  f_explicit::Vector{Element{T}}
  s_explicit::Vector{Element{T}}
  f_compressed::Vector{Pair{T}}
  s_compressed::Vector{Pair{T}}
end

typealias IntStack CompressedStack{Int}
typealias IntElement Element{Int}
function zero(::Type{IntElement})
  IntElement(0,0)
end
typealias IntPair Pair{Int}
function zero(::Type{IntPair})
  IntPair(zero(::Type{IntElement}),zero(::Type{IntElement}))
end
function IntStack(input_size::Int, space::Int)
  h = convert(Int,ceil(log(space,input_size))) - 1
  compressed_tail = zeros{IntPair}(input_size)
  explicit_first = Vector{IntElement}(input_size)
  explicit_second = Vector{IntElement}(input_size)
  println("h=$h size=$input_size space=$space")
  println(log(space,input_size))
  println(typeof(h))
  compressed_first = Vector{IntPair}(h-1)
  compressed_second = Vector{IntPair}(h-1)
  IntStack(compressed_tail, explicit_first, explicit_second, compressed_first,
  compressed_second)
end

typealias FloatStack CompressedStack{Float64}
typealias IntVectStack CompressedStack{Vector{Int}}

function print(stack::CompressedStack)
  println("Compressed Stack with input size ",0," and limited space ",0)
  println("\t Compressed tail:")
  print(stack.compressed)
  println("\n\t First:")
  println("\t\t (first) explicit ->")
  print(stack.f_explicit)
  println("\t\t (first) compressed ->")
  print(stack.f_compressed)
  println("\n\t Second:")
  println("\t\t (second) explicit ->")
  print(stack.s_explicit)
  println("\t\t (second) compressed ->")
  print(stack.s_compressed)
end

function stack_test(size::Int, space::Int)
  stack = IntStack(size,space)

  print(stack)
end

end # module
