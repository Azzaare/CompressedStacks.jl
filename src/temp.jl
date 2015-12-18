function io_test()
  function condition_push(stack::CompressedStack, elt::Int)
    line = readline(stack.input)
    aux = split(line)
    return convert(Bool, elt)
  end

  function condition_pop(stack::CompressedStack)
    return false
  end

  function action_push(stack::CompressedStack{Int,Int}, elt::Int)
    stack.context = Nullable(stack.index)
    print(stack)
  end

  function action_pop(stack::CompressedStack, elt::Int)
    println("Pop $elt")
  end

  context_type = Int
  data_type = Int

  name = "/home/jeff/.julia/v0.4/CompressedStacks/ioexample/input1"
  stack = CompressedStack(name, action_pop, action_push, condition_pop,
  condition_push, context_type, data_type)

  print(stack)
  run(stack)
  print(stack)
end