#### Redefinition of push! function for stacks
import Base.push!
## Push functions for CompressedStack : push!, push_compressed!, push_explicit!

# Method to compress a block into a signature
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

# Function push_explicit to push from input into the explicit blocks
function push_explicit!{T,D}(stack::CompressedStack{T,D}, elt::D)
  data = Data(elt, stack.index)
  if isempty(stack.first_explicit)
    push!(stack.first_explicit, data)
    sign = Signature(stack.index, get(stack.context), deepcopy(stack.input))
    stack.first_sign = Nullable(sign)
  else
    head = top(stack)
    start_block = head - mod(head - 1, stack.space)
    if stack.index - start_block < stack.space
      push!(stack.first_explicit,data)
      update_signature!(get(stack.first_sign), stack.index)
    else
      if stack.depth == 1 && !isempty(stack.second_explicit)
        if isnull(stack.compressed)
          stack.compressed = stack.second_sign
        else
          update_signature!(get(stack.compressed), get(stack.second_sign).last)
        end
      end
      stack.second_sign = stack.first_sign
      sign = Signature(stack.index, get(stack.context), deepcopy(stack.input))
      stack.first_sign = Nullable(sign)
      stack.second_explicit = stack.first_explicit
      stack.first_explicit = [data]
    end
  end
end

# Function to push (possibly fully) compressed index of new data from input
function push_compressed!{T,D}(stack::CompressedStack{T,D}, lvl::Int)
  dist_subblock = stack.space^(stack.depth - lvl)
  dist_block = dist_subblock * stack.space

  if isempty(stack, lvl)
    input_copy = deepcopy(stack.copy_input)
    sign = Signature(stack.index, get(stack.context),input_copy)
    push!(stack.first_partial[lvl], sign)
  else
    head = top(stack.first_partial[lvl])
    start_block = head - mod(head - 1, dist_block)
    # distance of the new index and current block
    δ = stack.index - start_block + 1
    if δ <= dist_block
      # Distance with the current subblock
      start_subblock = head - mod(head - 1, dist_subblock)
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


#####################
## push! for NormalStack
function push!{D}(stack::NormalStack, elt::D)
  stack.push_action(stack, elt)
  data = Data(elt, stack.index)
  push!(stack.data, data)
end
