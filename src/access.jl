### Access to the elements of a stack or sub structures
import Base.isempty

## Testing if a Stack is empty
# CompressedStack
function isempty(stack::CompressedStack)
  bfirst = isempty(stack.first_partial) || isempty(stack.first_partial[1])
  bsecond = isempty(stack.second_partial) || isempty(stack.second_partial[1])
  bcompressed = isnull(stack.compressed)
  bexplicit = isempty(stack.first_explicit) && isempty(stack.second_explicit)
  return bfirst && bsecond && bcompressed && bexplicit
end
function isempty(stack::CompressedStack, lvl::Int)
  if lvl < stack.depth
    return isempty(stack.first_partial[lvl])
  else
    return isempty(stack.first_explicit)
  end
end

# NormalStack
function isempty(stack::NormalStack)
  isempty(stack.data)
end

## Reading the top explicit element of a CompressedStack
function top_explicit(stack::CompressedStack)
  if isempty(stack.first_explicit)
    stack.second_explicit[end].index
  else
    stack.first_explicit[end].index
  end
end

## Reading the top element
# Normal Stacks
function top(stack::NormalStack)
  d = stack.data[end]
  return d.index
end

# Compressed Stacks
function top{T}(block::Block{T})
  return block[end].last
end


function top{T}(stack::CompressedStack{T})
  if !isempty(stack.first_partial) && !isempty(stack.first_partial[1])
    top(stack.first_partial[1])
  elseif !isempty(stack.second_partial) && !isempty(stack.second_partial[1])
    top(stack.second_partial[1])
  elseif !isempty(stack.first_explicit) || !isempty(stack.second_explicit)
    top_explicit(stack)
  else
    return get(stack.compressed).last
  end
end

## Reading bottom element
# Block
function bottom{T}(block::Block{T})
  return block[end].first
end

## Update top elements
# Used in pop.jl
function update_top!{T}(block::Block{T}, index::Int)
  block[end].last = index
end
# Used in push.jl
function update_top!{T}(block::Block{T}, subblock::Int, index::Int)
  block[subblock].last = index
end
