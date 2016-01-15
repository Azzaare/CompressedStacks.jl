### Action for Compressed Stack's internals mechanisms ###

## Import in CompressedStack.jl
# import Base.push!, Base.pop!, Base.isempty

## General Dequeues/Stack functions ##

# Testing if a CompressedStack is empty
function isempty(stack::CompressedStack)
  bfirst = isempty(stack.first_partial) || isempty(stack.first_partial[1])
  bsecond = isempty(stack.second_partial) || isempty(stack.second_partial[1])
  bcompressed = isnull(stack.compressed)
  return bfirst && bsecond && bcompressed
end

function isempty(stack::CompressedStack, lvl::Int)
  if lvl < stack.depth
    return isempty(stack.first_partial[lvl])
  else
    return isempty(stack.first_explicit)
  end
end

# Read/Write Compressed Block
function read_top{T}(block::Block{T})
  return block[end].last
end

function read_top{T}(stack::CompressedStack{T})
  if isempty(stack.first_partial)
    read_explicit(stack)
  elseif isempty(stack.first_partial[1])
    return read_top(stack.second_partial[1])
  else
    return read_top(stack.first_partial[1])
  end
end

function read_bottom{T}(block::Block{T})
  return block[end].first
end

function read_explicit(stack::CompressedStack)
  if isempty(stack.first_explicit)
    stack.second_explicit[end].index
  else
    stack.first_explicit[end].index
  end
end

function update_top!{T}(block::Block{T}, index::Int)
  block[end].last = index
end

function update_top!{T}(block::Block{T}, subblock::Int, index::Int)
  block[subblock].last = index
end

function compress!{T}(stack::CompressedStack,
  sign::Nullable{Signature{T}}, block::Block{T})

  if isempty(block)
    sign = Nullable{Signature}()
  else
    if isnull(sign)
      sign = Nullable(Signature(block))

    else
      get(sign).last = block[end].last
    end
  end
  stack.compressed = sign
end

## Push functions for CompressedStack : push!, push_compressed!, push_explicit!

# Function push_explicit to push from input into the explicit blocks
function push_explicit!{T,D}(stack::CompressedStack{T,D}, elt::D)
  data = Data(elt, stack.index)
  if isempty(stack.first_explicit)
    push!(stack.first_explicit, data)
  else
    top = read_top(stack)
    start_block = top - mod(top - 1, stack.space)
    if stack.index - start_block < stack.space
      push!(stack.first_explicit,data)
    else
      stack.second_explicit = stack.first_explicit
      stack.first_explicit = [data]
    end
  end
end

# Function to push (possibly fully) compressed index of new data from input
function push_compressed!{T,D}(stack::CompressedStack{T,D}, lvl::Int)
  p = stack.space^(lvl)
  dist_block = stack.size / p
  dist_subblock = dist_block / stack.space

  if isempty(stack, lvl)
    input_copy = deepcopy(stack.copy_input)
    sign = Signature(stack.index, get(stack.context),input_copy)
    push!(stack.first_partial[lvl], sign)
  else
    top = read_top(stack.first_partial[lvl])
    start_block = top - mod(top - 1, dist_block)
    # distance of the new index and current block
    δ = stack.index - start_block + 1
    if δ <= dist_block
      # Distance with the current subblock
      start_subblock = top - mod(top - 1, dist_subblock)
      η = stack.index - start_subblock + 1
      # compress new element in the top of the current Block
      if η <= dist_subblock
        subblock = length(stack.first_partial[lvl])
        update_top!(stack.first_partial[lvl], subblock, stack.index)
      else
        input_copy = deepcopy(stack.copy_input)
        sign = Signature(stack.index, get(stack.context), input_copy)
        push!(stack.first_partial[lvl], sign)
      end
    else
      if lvl == 1
        compress!(stack, stack.compressed, stack.second_partial[1])
      end
      stack.second_partial[lvl] = stack.first_partial[lvl]
      input_copy = deepcopy(stack.copy_input)
      sign = Signature(stack.index, get(stack.context), input_copy)
      stack.first_partial[lvl] = [sign]
    end
  end
end

# Function push! that push the data in explicit and index in partial/compressed
function push!{T,D}(stack::CompressedStack{T,D}, elt::D)
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
function reconstruct!(stack::CompressedStack)
  for i in 1:stack.depth # lvl = h - i; 0 is for the fully compressed part
    lvl = stack.depth - i
    if lvl == 0
      sign = get(stack.compressed)
      return reconstruct!(stack, sign, lvl + 1)
    else
      if !isempty(stack.first_partial[lvl])
        sign = stack.first_partial[lvl][end]
        return reconstruct!(stack, sign, lvl + 1)
      elseif !isempty(stack.second_partial[lvl])
        sign = stack.second_partial[lvl][end]
        return reconstruct!(stack, sign, lvl + 1)
      end
    end

  end
end
function reconstruct!(stack::CompressedStack, sign::Signature, lvl::Int)
  size = stack.space ^ (stack.depth + 1 - lvl)
  aux = CompressedStack(stack, size, sign.input, sign.context, sign.first - 1)

  run!(aux, sign.last - sign.first)
  δ = stack.depth - aux.depth

  println("⇒   Auxiliary stack for reconstruction")
  print(aux)

  for i in 1:(aux.depth-1)
    stack.second_partial[δ + i] = aux.first_partial[i]
  end
  if lvl == 1
    compress!(stack, aux.compressed, aux.second_partial[1])
  end
  stack.second_explicit = aux.first_explicit

  aux = 0
  gc()

end


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
  index = read_top(stack)
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
  index = read_top(stack)
  elt = pop!(stack.second_explicit)
  stack.pop_action(stack, elt.data)
  if isempty(stack.second_explicit)
    empty_second!(stack, index, stack.depth - 1)
  else
    new_index = stack.second_explicit[end].index
    propagate_second!(stack, new_index, stack.depth - 1)
  end
end

function pop!(stack::CompressedStack)
  if !isempty(stack.first_explicit)
    pop_first!(stack)
  else
    if isempty(stack.second_explicit)
      println("Starting reconstruction")
      print(stack)
      reconstruct!(stack)
      print(stack)
      println("⟸   Reconstructed stack")
    end
    pop_second!(stack)
  end
end
