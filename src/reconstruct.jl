### reconstruct procedure for Compressed Stacks

## Look for the first level of information available to reconstruct
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

## Reconstruct an auxiliary stack based on the signature found above
function reconstruct!(stack::CompressedStack, sign::Signature, lvl::Int)
  size = stack.space ^ (stack.depth + 1 - lvl)
  aux = CompressedStack(stack, size, sign.input, sign.context, sign.first - 1)

## Call the run! function in run.jl
  run!(aux, sign.last - sign.first)
  δ = stack.depth - aux.depth

  for i in 1:(aux.depth-1)
    stack.second_partial[δ + i] = aux.first_partial[i]
  end
  if lvl == 1
    compress!(stack, aux.compressed, aux.second_partial[1])
  end
  stack.second_explicit = aux.first_explicit

## Clean the memory
  aux = 0
  gc()
end
