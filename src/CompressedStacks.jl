### Julia module for the Compressed Stack structure ###
module CompressedStacks

## Import/Export
import Base.print, Base.string # to use in io.jl
import Base.push!, Base.pop!, Base.isempty # to use in stack.jl

## Basic types and constructors for CompressedStack
include("base.jl")

## I/O for Compressed Stack structure
include("io.jl")

## Action for Compressed Stack's internals mechanisms
include("intern.jl")

## Specialized types of Compressed Stacks

## Function to run a CompressedStack similarly than for a classic stack
function run(stack::CompressedStack)
  while !eof(stack.input)
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
    end
    elt = readinput(stack)
    println(typeof(elt))
    if stack.push_condition(stack,elt)
      push!(stack, elt)
    end
  end
end

## Testing part
include("temp.jl")

end ### of CompressedStacks module
