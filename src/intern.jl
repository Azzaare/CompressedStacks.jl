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
function read_top{T}(block::Block{T})
  return block[end].last
end

function read_top{T}(stack::CompressedStack{T})
  if isempty(stack.first_partial[1])
    return read_top(stack.second_partial[1])
  else
    return read_top(stack.first_partial[1])
  end
end

function read_bottom{T}(block::Block{T})
  return block[end].first
end

function update_top!{T}(block::Block{T}, index::Int)
  block[end].last = index
end

function update_top!{T}(block::Block{T}, subblock::Int, index::Int)
  block[subblock].last = index
end

function compress!{T}(sign::Nullable{Signature{T}}, block::Block{T})
  if isempty(block)
    sign = Nullable{Signature}()
  else
    if isnull(sign)
    sign = Nullable(Signature(block))
    else
      compress!(sign, block[end].last)
    end
  end
end
function compress!{T}(sign::Signature{T}, index::Int)
  sign.last = index
end

## Push functions for CompressedStack : push!, push_compressed!, push_explicit!

# Function push_explicit to push from input into the explicit blocks
function push_explicit!{T,D}(stack::CompressedStack{T,D}, elt::D)
  if isempty(stack.first_explicit)
    push!(stack.first_explicit, elt)
  else
    top = read_top(stack)
    start_block = top - mod(top - 1, stack.space)
    if stack.index - start_block < stack.space
      push!(stack.first_explicit,elt)
    else
      stack.second_explicit = stack.first_explicit
      stack.first_explicit = [elt]
    end
  end
end

# Function to push (possibly fully) compressed index of new data from input
function push_compressed!{T,D}(stack::CompressedStack{T,D}, lvl::Int)
  p = stack.space^(lvl)
  dist = stack.size / p
  cpt = 0
  println("print test")

  if isempty(stack, lvl)

    println("print test 2")
    cpt += 1
    input_copy = deepcopy(stack.input)
    sign = Signature(stack.index, get(stack.context),input_copy)
    println(length(stack.first_partial))
    println("cpt=$cpt")

    println("lvl=$lvl ",stack.first_partial[2])

    push!(stack.first_partial[lvl], sign)
  else
    println("print test 3")
    top = read_top(stack.first_partial[lvl])
    start_block = top - mod(top - 1, dist)
    δ = stack.index - start_block + 1 # distance of the new index and current block
    println("print test 3.1")
    if δ <= dist
      println("print test 4")
      # compress new element in the top of the current Block
      subblock = convert(Int, ceil(δ * stack.space / dist))
      println("subblock=$subblock")
      println("δ=$δ, dist/space=$(dist / stack.space)")
      if length(stack.first_partial[lvl]) < subblock
        println("print test 5")
        input_copy = deepcopy(stack.input)
        sign = Signature(stack.index, get(stack.context), input_copy)
        push!(stack.first_partial[lvl], sign)
      else
        println("print test 6: lvl=$lvl, subblock=$subblock")
        print(stack)
        update_top!(stack.first_partial[lvl], subblock, stack.index)
      end
    else
      if lvl == 1
        compress!(stack.compressed, stack.second_partial[1])
      end
      stack.second_partial[lvl] = stack.first_partial[lvl]
      input_copy = deepcopy(stack.input)
      sign = Signature(stack.index, get(stack.context), input_copy)
      stack.first_partial[lvl] = []
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
function aux_stack(stack::CompressedStack, lvl::Int)
  if lvl == 1
    context = stack.compressed.context
    input = stack.compressed.input
    size = stack.compressed.last - stack.compressed.first + 1
  else
    context = stack.second_partial[lvl-1][end].context
    input = stack.second_partial[lvl-1][end].input
    size = stack.second_partial[lvl].last - stack.second_partial[lvl].first + 1
  end
  return CompressedStack(stack, size, input, context)
end


function reconstruct!(stack::CompressedStack, lvl::Int)
  aux = aux_stack(stack, lvl) # Reconstructed block

  # Copy explicit values
  stack.second_explicit = aux.first_explicit
  # Copy partially compressed values
  for i in lvl:(stack.depth-1)
    stack.second_partial[i] = aux.first_partial[i]
  end
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
