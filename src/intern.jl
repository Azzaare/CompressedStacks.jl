### Action for Compressed Stack's internals mechanisms ###

## Import in CompressedStack.jl
# import Base.push!, Base.pop!, Base.isempty

## General Dequeues/Stack functions ##

# Testing if a CompressedStack is empty
function isempty(stack::CompressedStack)
  return isempty(stack.first_explicit) && isempty(stack.second_explicit)
end

function isempty(stack::CompressedStack, lvl::Int)
  if lvl < stack.depth
    return isempty(stack.first_partial[lvl])
  else
    return isempty(stack.first_explicit)
  end
end

# Read/Write Compressed Block
function compress!{T}(sign::Signature{T}, block::Block{T})
  compress!(sign, block[end].last)
end
function compress!{T}(sign::Signature{T}, index::Int)
  sign.last = index
end

function read_top{T}(block::Block{T})
  return block[end].last
end

function read_bottom{T}(block::Block{T})
  return block[end].first
end

function update_top!{T}(block::Block{T}, index::Int)
  block[end].last = index
end

## Push functions for CompressedStack : push!, push_compressed!, push_explicit!

# Function push_explicit to push from input into the explicit blocks
function push_explicit!{T,D}(stack::CompressedStack{T,D}, elt::D)
  bool1 = mod(stack.index,stack.space) == 1
  if isempty(stack.first_explicit)
    push!(stack.first_explicit,elt)
  elseif bool1 || stack.index - stack.first_explicit[end] >= stack.space
    stack.second_explicit = stack.first_explicit
    stack.first_explicit = [elt]
  else
    push!(stack.first_explicit,elt)
  end
end

# Function to push (possibly fully) compressed index of new data from input
function push_compressed!{T,D}(stack::CompressedStack{T,D}, lvl::Int)
  p = stack.space^(lvl + 1)
  dist = stack.size / p

  if isempty(stack, lvl)
    push!(stack.first_partial[lvl],Signature(stack.index, get(stack.context)))
  else
    top = read_top(stack.first_partial[lvl])
    start_block = top - mod(top - 1, p)
    if stack.index - start_block < dist
      # compress new element into block of level i
      update_top!(stack.first_partial[lvl], stack.index)
    elseif stack.index - start_block <= dist * stack.space
      push!(stack.first_partial[lvl],Signature(stack.index, get(stack.context)))
    else
      if lvl == 1
        compress!(stack.compressed,stack.second_partial)
      end
      stack.second_partial[lvl] = stack.first_partial[lvl]
      stack.first_partial[lvl] = [Signature(stack.index, get(stack.context))]
    end
  end
end

# Function push! that push the data in explicit and index in partial/compressed
function push!{T,D}(stack::CompressedStack{T,D}, elt::D)
  stack.index += 1
  stack.push_action(stack, elt)
  # update the explicit Blocks, with possibly shifting first to second
  push_explicit!(stack, elt)
  # update the compressed Blocks at each levels (including the fully compressed)
  for lvl in 1:(stack.depth - 1)
    push_compressed!(stack, lvl)
  end
end


### Pop functions for CompressedStack ###

## Reconstruct of a block in an auxiliary CompressedStack
function reconstruct!{T,D}(stack::CompressedStack{T,D}, lvl::Int)
  println("Implement reconstruct!")
end

## Functions that empty (pop) the element in partially compressed blocks
function empty_first!(stack::CompressedStack, index::Int, lvl::Int)
  if stack.first_partial[lvl][1] == index
    pop!(stack.first_partial[lvl])
    if lvl > 1
      empty_first!(stack, index, lvl-1)
    end
  else
    propagate_first!(stack, index, lvl)
  end
end

function empty_second!(stack::CompressedStack, index::Int, lvl::Int)
  if !isempty(stack.first_partial[lvl])
    empty_first!(stack, index, lvl)
  elseif stack.second_partial[lvl][1] == index
    pop!(second_partial[lvl])
    if lvl > 1
      empty_second!(stack, index, lvl - 1)
    else
      reconstruct!(stack, 0)
    end
  else
    propagate_second!(stack, index, lvl)
    reconstruct!(stack, lvl + 1)
  end
end

## Functions to propagate the index of the element that have been popped
function propagate_first!(stack::CompressedStack, index::Int, lvl::Int)
  for i in 1:lvl
    update_top!(stack.first_partial[i], index)
  end
end

function propagate_second!(stack::CompressedStack, index::Int, lvl::Int)
  if isempty(stack.first_partial[lvl])
    update_top!(stack.second_partial[lvl], index)
    if lvl > 1
      propagate_second!(stack, index, lvl - 1)
    end
  else
    propagate_first!(stack, index, lvl)
  end
end

## Functions to pop from first/second partial and from explicit
function pop_first!(stack::CompressedStack)
  elt = pop!(stack.first_explicit)
  index = stack.first_partial[end][end].last
  stack.pop_action(stack, elt)
  if isempty(stack.first_explicit)
    empty_first!(stack, index, stack.depth - 1)
  else
    propagate_first!(stack, index, stack.depth - 1)
  end
end

function pop_second!(stack::CompressedStack)
  elt = pop!(stack.second_explicit)
  stack.pop_action(stack, elt)
  if isempty(stack.second_explicit)
    empty_second!(stack, index, stack.depth - 1)
  else
    propagate_second!(stack, index, stack.depth - 1)
  end
end

function pop!(stack::CompressedStack)
  if isempty(stack.first_explicit)
    pop_second!(stack)
  else
    pop_first!(stack)
  end
end
