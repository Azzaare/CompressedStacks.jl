module CompressedStacks
import Base.print, Base.zero

type Pair
  first::Int
  last::Int
end

type CompressedStack
  compressed::Vector{Pair}
  f_explicit::Vector{Int}
  s_explicit::Vector{Int}
  f_compressed::Vector{Pair}
  s_compressed::Vector{Pair}
end

function CompressedStack(input_size::Int, space::Int)
  h = convert(Int,ceil(log(space,input_size))) - 1
  compressed_tail = zeros{Pair}(input_size)
  explicit_first = Vector{Int}(input_size)
  explicit_second = Vector{Int}(input_size)
  println("h=$h size=$input_size space=$space")
  println(log(space,input_size))
  println(typeof(h))
  compressed_first = Vector{Pair}(h-1)
  compressed_second = Vector{Pair}(h-1)
  CompressedStack(compressed_tail, explicit_first, explicit_second, compressed_first,
  compressed_second)
end

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
  stack = CompressedStacks(size,space)
  print(stack)
end

end # module
