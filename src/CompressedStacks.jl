module CompressedStacks

include("type.jl")
include("stack.jl")
include("io.jl")

## Testing part

function case_input()
  input = zeros(Bool,81)
  for i in [3,26,30,37,38,39,41,42,44,55,56,57]
    input[i] = true
  end
  return input
end

function stack_test(size::Int, space::Int)
  stack = CompressedStack(size,space,case_input())
  stack.compressed = Pair(3,26)
  push!(stack.f_explicit,55,56,57)
  push!(stack.s_explicit,44)
  push!(stack.f_compressed[1],Pair(55,57))
  push!(stack.f_compressed[2],Pair(55,57))
  push!(stack.s_compressed[1],Pair(30,30))
  push!(stack.s_compressed[1],Pair(37,44))
  push!(stack.s_compressed[2],Pair(37,39))
  push!(stack.s_compressed[2],Pair(41,42))
  push!(stack.s_compressed[2],Pair(44,44))
  print(stack)
  pop!(stack)
  print(stack)
  pop!(stack)
  print(stack)
  pop!(stack)
  print(stack)
  pop!(stack)
  print(stack)
end

function push_test(size::Int, space::Int)
stack = CompressedStack(size,space,case_input())
  stack.compressed = Pair(3,26)
  push!(stack.f_explicit,55,56,57)
  push!(stack.s_explicit,44)
  push!(stack.f_compressed[1],Pair(55,57))
  push!(stack.f_compressed[2],Pair(55,57))
  push!(stack.s_compressed[1],Pair(30,30))
  push!(stack.s_compressed[1],Pair(37,44))
  push!(stack.s_compressed[2],Pair(37,39))
  push!(stack.s_compressed[2],Pair(41,42))
  push!(stack.s_compressed[2],Pair(44,44))
  print(stack)
  push!(stack,58)
  print(stack)
  push!(stack,75)
  print(stack)
end

end # module
