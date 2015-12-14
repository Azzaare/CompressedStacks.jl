module CompressedStacks

include("type.jl")
include("stack.jl")
include("io.jl")

## Testing part

function push_condition()
  return rand(Bool)
end
function pop_condition()
  return rand(Bool)
end
function push_action()
  println("Push Action")
end
function pop_action()
  println("Pop Action")
end
function int_stack(size::Int, space::Int)
  stack = CompressedStack(size, space, Int, push_condition, push_action,
  pop_condition, pop_action, context = Nullable(10))
  stack.compressed = Nullable(ExtPair(3,26,0))
  push!(stack.f_explicit,55,56,57)
  push!(stack.s_explicit,44)
  print(stack)
  push!(stack.f_compressed[1],ExtPair(55,57,0))
  push!(stack.f_compressed[2],ExtPair(55,57,0))
  push!(stack.s_compressed[1],ExtPair(30,30,0))
  push!(stack.s_compressed[1],ExtPair(37,44,0))
  push!(stack.s_compressed[2],ExtPair(37,39,0))
  push!(stack.s_compressed[2],ExtPair(41,42,0))
  push!(stack.s_compressed[2],ExtPair(44,44,0))
  return stack
end

function stack_test(size::Int, space::Int)
  stack = int_stack(size, space)
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
  stack = int_stack(size, space)
  print(stack)
  push!(stack,58)
  print(stack)
  push!(stack,75)
  print(stack)
end

end # module
