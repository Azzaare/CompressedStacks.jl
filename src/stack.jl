### File with the basic stack functions for CompressedStack

## Import
import Base.push!, Base.pop!

# Read/Write Compressed Block
function compress!(c::Pair,v::Level)
  compress!(v[end].last,c)
end
function compress!(elt::Int,p::Pair)
  p.last = elt
end

function read_top(v::Level)
  return v[end].last
end

function read_bottom(v::Level)
  return v[end].first
end

function update_top!(v::Level, elt::Int)
  v[end].last = elt
end

# Push function for Compressed Stacks
function push_explicit!(stack::CompressedStack, elt::Int)
  if (mod(elt,stack.space) == 1) || (elt - stack.f_explicit[end] >= stack.space)
    stack.s_explicit = stack.f_explicit
    stack.f_explicit = [elt]
  else
    push!(stack.f_explicit,elt)
  end
end

function push_compressed!(stack::CompressedStack, lvl::Int, elt::Int)
  p = stack.space^(lvl+1)
  dist = stack.size / p
  top = read_top(stack.f_compressed[lvl])
  start_block = top - mod(top-1,p)
  if elt - start_block < dist
    update_top!(stack.f_compressed[lvl], elt) # compress new element into block of level i
  elseif elt - start_block <= dist * stack.space
    push!(stack.f_compressed[lvl],Pair(elt))
  else
    if lvl == 1
      compress!(stack.compressed,stack.s_compressed)
    end
    stack.s_compressed[lvl] = stack.f_compressed[lvl]
    stack.f_compressed[lvl] = [Pair(elt)]
  end
end

function push!(stack::CompressedStack, elt::Int)
  push_explicit!(stack, elt) ## update the explicit vectors, with possibly shifting first to second beforehand
  for i in 1:(stack.depth-1)
    push_compressed!(stack, i, elt)
  end
end

## pop for CompressedStack
function reconstruct!(stack::CompressedStack, lvl::Int, start::Int, stop::Int, context::Int)
  println("Implement reconstruct!")
end

function empty_first!(stack::CompressedStack, elt::Int, lvl::Int)
  if stack.f_compressed[lvl][1] == elt
    pop!(stack.f_compressed[lvl])
    if lvl > 1
      empty_first!(stack, elt, lvl-1)
    end
  else
    propagate_first!(stack, elt, lvl)
  end
end

function empty_second!(stack::CompressedStack, elt::Int, lvl::Int)
  if !isempty(stack.f_compressed[lvl])
    empty_first!(stack, elt, lvl)
  elseif stack.s_compressed[lvl][1] == elt
    pop!(s_compressed[lvl])
    if lvl > 1
      empty_second!(stack, elt, lvl - 1)
    else
      reconstruct!(stack, 0, stack.compressed_tail[1], stack.compressed_tail[end], 0)
    end
  else
    propagate_second!(stack, elt, lvl)
    reconstruct!(stack, lvl + 1, stack.s_compressed[1], stack.s_compressed[end])
  end
end

function propagate_first!(stack::CompressedStack, elt::Int, lvl::Int)
  for i in 1:lvl
    update_top!(stack.f_compressed[i],elt)
  end
end

function propagate_second!(stack::CompressedStack, elt::Int, lvl::Int)
  if isempty(stack.f_compressed[lvl])
    update_top!(stack.s_compressed[lvl], elt)
    if lvl > 1
      propagate_second!(stack, elt, lvl - 1)
    end
  else
    propagate_first!(stack, elt, lvl)
  end
end

function pop_first!(stack)
  elt = pop!(stack.f_explicit)
  println("To implement: pop_action()")
  if isempty(stack.f_explicit)
    empty_first!(stack, elt, stack.depth-1)
  else
    propagate_first!(stack, stack.f_explicit[end], stack.depth-1)
  end
end

function pop_second!(stack::CompressedStack)
  elt = pop!(stack.s_explicit)
  println("To implement: pop_action()")
  if isempty(stack.s_explicit)
    empty_second!(stack, elt, stack.depth - 1)
  else
    propagate_second!(stack, elt, stack.depth - 1)
  end
end

function pop!(stack::CompressedStack)
  if isempty(stack.f_explicit)
    pop_second!(stack)
  else
    pop_first!(stack)
  end
end
