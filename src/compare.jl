### File to compare the behavior of normal and compressed stacks

function run!(cs::CompressedStack, ns::NormalStack)
  while !eof(cs.input)
    if eof(ns) != eof(cs.input)
      error("The two stacks have different input reading")
    elseif isempty(cs) != isempty(ns)
      error("Only one of the two stacks is empty")
    elseif cs.pop_condition(cs) != ns.pop_condition(ns)
      error("The pop conditions of the stacks give different boolean values")
    end
    while !isempty(cs) && cs.pop_condition(cs)
      pop!(cs)
      pop!(ns)
      if top(ns) != read_top(cs)
        error("The top element of the stacks are different after a pop!")
      end
    end
    elt = readinput(cs)
    if elt != readinput(ns)
      error("The content in the input file are read differently before a push!")
    elseif cs.push_condition(cs,elt) != ns.push_condition(ns,elt)
      error("The push conditions of the stacks give different boolean values")
    end
    if cs.push_condition(cs, elt)
      push!(cs, elt)
    end
  end
end
