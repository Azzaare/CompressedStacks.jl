function io_test()
  function condition_push(stack::CompressedStack, elt::Int)
    f = deepcopy(stack.input)
    line = readline(f)
    aux = split(line)
    return convert(Bool, elt)
  end
  function condition_push2(stack::NormalStack, elt::Int)
    f = deepcopy(stack.input)
    line = readline(f)
    aux = split(line)
    return convert(Bool, elt)
  end

  function condition_pop(stack::CompressedStack)
    if stack.index >= 80
      return true
    else
      return false
    end
  end
  function condition_pop2(stack::NormalStack)
    if stack.index >= 80
      return true
    else
      return false
    end
  end

  function action_push(stack::CompressedStack{Int,Int}, elt::Int)
    stack.context = Nullable(stack.index)
    # print(stack)
  end
  function action_push2(stack::NormalStack{Int,Int}, elt::Int)
    stack.context = Nullable(stack.index)
    # print(stack)
  end

  function action_pop(stack::CompressedStack, elt::Int)
    #println("Pop element : $elt")
  end
  function action_pop2(stack::NormalStack, elt::Int)
    #println("Pop element : $elt")
  end

  context_type = Int
  data_type = Int

  name = "/home/azzaare/.julia/v0.4/CompressedStacks/ioexample/input1"

  ns = NormalStack(name, action_pop2, action_push2, condition_pop2,
  condition_push2, context_type, data_type)

  cs = CompressedStack(name, action_pop, action_push, condition_pop,
  condition_push, context_type, data_type)

  run!(cs)
  run!(ns)
  run!(cs,ns)
end
