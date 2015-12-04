### File with the basic stack functions for CompressedStack

## Import
import Base.push!, Base.pop!

# Compress functions
function compress!(c::Pair,v::Level)
  compress!(v[end].last,c)
end
function compress!(elt::Int,p::Pair)
  p.last = elt
end

# Read/Write Compressed Block
function read_top(v::Level)
  return v[end].last
end
function reduce_block!(v::Level, elt::Int)
  v[end].last = elt
end

# Push or pop element
function push!(stack::CompressedStack, elt::Int)
  if (mod(elt,stack.space) == 1) || (elt - stack.f_explicit[end] >= stack.space)
    stack.s_explicit = stack.f_explicit
    stack.f_explicit = [elt]
  else
    push!(stack.f_explicit,elt)
  end
  i = stack.depth - 1
  while i > 0
    p_i = stack.space^(i+1)
    dist = stack.size / p_i
    top = stack.f_compressed[i][end].last
    start_block = top - mod(top-1,p_i)
    if elt - start_block < dist
      compress!(elt,stack.f_compressed[i][end])
    elseif elt - start_block <= dist * stack.space
      push!(stack.f_compressed[i],Pair(elt,elt))
    else
      if i == 1
        compress!(stack.compressed,stack.s_compressed)
      end
      stack.s_compressed[i] = stack.f_compressed[i]
      stack.f_compressed[i] = [Pair(elt,elt)]
    end
    i -= 1
  end
end

function push2!(stack::CompressedStack, elt::Int, lvl::Int)
  if (mod(elt,stack.space) == 1) || (elt - stack.s_explicit[end] >= stack.space)
    stack.s_explicit = stack.f_explicit
    stack.f_explicit = [elt]
  else
    push!(stack.f_explicit,elt)
  end
end

function reconstruct(stack::CompressedStack, lvl::Int)
  bottom = stack.s_compressed[lvl][end].first
  top = stack.s_compressed[lvl][end].last
  for i in bottom:top
    println("$i")
  end
end

function pop!(stack::CompressedStack)
  l = length(stack.f_explicit)
  if l > 0 ## Check f_explicit
    elt = pop!(stack.f_explicit)
    i = stack.depth - 1
    while i > 0
      if (i == stack.depth - 1) && isempty(stack.f_explicit)
        pop!(stack.f_compressed[i])
      elseif (i < stack.depth - 1) && isempty(stack.f_compressed[i+1])
        pop!(stack.f_compressed[i])
      else
        if i == stack.depth - 1
          elt = stack.f_explicit[end]
        else
          elt = stack.f_compressed[i+1][end].last
        end
        break;
      end
      i -= 1
    end
    while i > 0
      reduce_block!(stack.f_compressed[i],elt)
      i -= 1
    end
  else ## Check s_explicit
    l = length(stack.s_explicit)
    if l > 0
      elt = pop!(stack.s_explicit)
      i = stack.depth - 1
      while i > 0
        if (i == stack.depth - 1) && isempty(stack.s_explicit)
          pop!(stack.s_compressed[i])
        elseif (i < stack.depth - 1) && isempty(stack.s_compressed[i+1])
          pop!(stack.s_compressed[i])
        else
          if i == stack.depth - 1
            elt = stack.s_explicit[end]
          else
            elt = stack.s_compressed[i+1][end].last
          end
          break;
        end
        i -= 1
      end
      ## reconstruction of lower levels
      reconstruct(stack,i+1)
      while i > 0
        reduce_block!(stack.s_compressed[i],elt)
        i -= 1
      end
    end
  end
end
