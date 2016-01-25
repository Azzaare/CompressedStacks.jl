### File for the run! function for Stacks
# Compressed Stack structure is efficient within this run method

### Functions to run a CompressedStack similarly than for a classic stack
function run!(stack::CompressedStack)
  while !eof(stack.input)
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end
# run! function specific to the reconstruction procedure of Compressed Stacks
function run!(stack::CompressedStack, limit::Int)
  while limit >= 0
    limit -= 1
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end

### For Normal Stacks
function run!(stack::NormalStack)
  while !eof(stack.input)
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
    end
  end
end

### Comparison between both Stacks
function run!(cs::CompressedStack, ns::NormalStack)
  while !eof(cs.input)
    if eof(ns.input) != eof(cs.input)
      error("The two stacks have different input reading")
    elseif isempty(cs) != isempty(ns)
      error("Only one of the two stacks is empty")
    elseif cs.pop_condition(cs) != ns.pop_condition(ns)
      error("The pop conditions of the stacks give different boolean values")
    end
    while !isempty(cs) && cs.pop_condition(cs)
      if top(ns) != top(cs)
              print(cs)
              print(ns)
        println("top: cs=$(top(cs)), ns=$(top(ns))")
        error("The top element of the stacks are different after a pop!")
      end
      pop!(cs)
      pop!(ns)
    end
    elt = readinput(cs)
    if elt != readinput(ns)
      error("The content in the input file are read differently before a push!")
    elseif cs.push_condition(cs,elt) != ns.push_condition(ns,elt)
      error("The push conditions of the stacks give different boolean values")
    end
    if cs.push_condition(cs, elt)
      push!(cs, elt)
      push!(ns, elt)
    end
  end
end
