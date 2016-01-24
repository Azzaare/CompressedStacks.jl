### pop! functions
import Base.pop!

# Include reconstruct procedures for Compressed Stacks
include("reconstruct.jl")

## Functions that empty (pop) the element in partially compressed blocks
function empty_first!(stack::CompressedStack, index::Int, lvl::Int)
  pop!(stack.first_partial[lvl])
  if lvl > 1
    if length(stack.first_partial[lvl]) == 0
      empty_first!(stack, index, lvl-1)
    else
      new_index = stack.first_partial[lvl][end].last
      propagate_first!(stack, new_index, lvl-1)
    end
  end
end

function empty_second!(stack::CompressedStack, index::Int, lvl::Int)
  if !isempty(stack.first_partial[lvl])
    empty_first!(stack, index, lvl)
  else
    pop!(stack.second_partial[lvl])
    if lvl > 1
      if length(stack.second_partial[lvl]) == 0
        empty_second!(stack, index, lvl-1)
      else
        new_index = stack.second_partial[lvl][end].last
        propagate_second!(stack, new_index, lvl-1)
      end
    end
  end
end

## Functions to propagate the index of the element that have been popped
function propagate_first!(stack::CompressedStack, index::Int, lvl::Int)
  for i in 1:lvl
    update_top!(stack.first_partial[i], index)
  end
end

function propagate_second!(stack::CompressedStack, index::Int, lvl::Int)
  if !isempty(stack.first_partial[lvl])
    propagate_first!(stack, index, lvl)
  else
    update_top!(stack.second_partial[lvl], index)
    if lvl > 1
      propagate_second!(stack, index, lvl - 1)
    end
  end
end

## Functions to pop from first/second explicit then from partial
function pop_first!(stack::CompressedStack)
  index = top(stack)
  elt = pop!(stack.first_explicit)
  stack.pop_action(stack, elt.data)
  if isempty(stack.first_explicit)
    empty_first!(stack, index, stack.depth - 1)
  else
    new_index = stack.first_explicit[end].index
    propagate_first!(stack, new_index, stack.depth - 1)
  end
end

function pop_second!(stack::CompressedStack)
  index = top(stack)
  elt = pop!(stack.second_explicit)
  stack.pop_action(stack, elt.data)
  if isempty(stack.second_explicit)
    empty_second!(stack, index, stack.depth - 1)
  else
    new_index = stack.second_explicit[end].index
    propagate_second!(stack, new_index, stack.depth - 1)
  end
end

## redefinition of pop! for Compressed Stacks
function pop!(stack::CompressedStack)
  if !isempty(stack.first_explicit)
    pop_first!(stack)
  else
    if isempty(stack.second_explicit)
      # Reconstruct the compressed stack with the first available signature
      # Implementation is in reconstruct.jl
      reconstruct!(stack)
    end
    pop_second!(stack)
  end
end

####################
## redefinition of pop! for Normal Stacks
function pop!(stack::NormalStack)
  elt = pop!(stack.data)
  stack.pop_action(stack, elt)
end
