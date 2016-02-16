### File for the run! function for Stacks
# Compressed Stack structure is efficient within this run method

### Functions to run a CompressedStack similarly than for a classic stack
function run!(stack::CompressedStack)
  while !eof(stack.input)
    elt = readinput(stack)
    while !isempty(stack) && stack.pop_condition(stack,elt)
      pop!(stack)
    end
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end
# run! function specific to the reconstruction procedure of Compressed Stacks
function run!(stack::CompressedStack, limit::Int)
  while limit >= 0
    elt = readinput(stack)
    limit -= 1
    while !isempty(stack) && stack.pop_condition(stack,elt)
      pop!(stack)
    end
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end

### Functions to run a CompressedStack with extra control on the pop condition
function runCountingPop!(stack::CompressedStack)
  while !eof(stack.input)
    elt = readinput(stack)
    popCounter=0
    while !isempty(stack) && stack.pop_condition(stack,elt,popCounter)
      pop!(stack)
      popCounter=popCounter+1
    end
    print(stack)
    println("LEAVING POP LOOOP!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! ",elt, " empty ",isempty(stack))
    #print(stack)
    if stack.push_condition(stack, elt)
      println("pushing ",elt)
      push!(stack, elt)
      print(stack)
    end
  end
end
# run! function specific to the reconstruction procedure of Compressed Stacks
function runCountingPop!(stack::CompressedStack, limit::Int)
  println("CALLED RUN COUNTING POP!")
  while limit >= 0
    elt = readinput(stack)
    limit -= 1
    popCounter=0
    while !isempty(stack) && stack.pop_condition(stack,elt,popCounter)
      pop!(stack)
      popCounter=popCounter+1
    end
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end




### For Normal Stacks
function run!(stack::NormalStack)
  while !eof(stack.input)
    elt = readinput(stack)
    while !isempty(stack) && stack.pop_condition(stack,elt)
      pop!(stack)
    end
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end


### Comparison between both Stacks
function run!(cs::CompressedStack, ns::NormalStack)
  println("\n\n!!!Start of the comparative run!!!\n")
  while !eof(cs.input)
    if eof(ns.input) != eof(cs.input)
      println("eof_ns = $(eof(ns.input)); eof_cs = $(eof(cs.input))")
      println("pos_ns = $(position(ns.input)); pos_cs = $(position(cs.input))")
      print(cs)
      print(ns)
      error("The two stacks have different input reading: eof")
    elseif isempty(cs) != isempty(ns)
      error("Only one of the two stacks is empty")
    end
    elt = readinput(cs)
    if elt != readinput(ns)
      error("The content in the input file are read differently before a push!")
    elseif cs.pop_condition(cs,elt) != ns.pop_condition(ns,elt)
      error("The pop conditions of the stacks give different boolean values")
    end

    while !isempty(cs) && cs.pop_condition(cs,elt)
      if top(ns) != top(cs)
              print(cs)
              print(ns)
        println("top: cs=$(top(cs)), ns=$(top(ns))")
        error("The top element of the stacks are different after a pop!")
      end
      pop!(cs)
      pop!(ns)
    end

    if cs.push_condition(cs,elt) != ns.push_condition(ns,elt)
      error("The push conditions of the stacks give different boolean values")
    end
    if cs.push_condition(cs, elt)
      push!(cs, elt)
      push!(ns, elt)
    end
  end
  println("\n\n!!!End of the comparative run!!!\n")
  print(cs)
  print(ns)
end
