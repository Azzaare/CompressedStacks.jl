### Julia module for the Compressed Stack structure ###
__precompile__() # Precompile option for the module. Is recompiled after changes
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
function run!(stack::CompressedStack)
  #println("⇒   Initial empty stack")
  #print(stack)

  while !eof(stack.input)
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
  #    println("⇒   Pop operation")
  #    print(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
  #    println("⇒   Push operation")
  #    print(stack)
    end
  end
end
function run!(stack::CompressedStack, limit::Int)
  while limit >= 0
    limit -= 1
    while !isempty(stack) && stack.pop_condition(stack)
      pop!(stack)
  #    println("⇒   Pop operation (during reconstruction)")
  #    print(stack)
    end
    elt = readinput(stack)
    if stack.push_condition(stack, elt)
      push!(stack, elt)
  #    println("⇒ Push operation (during reconstruction)")
  #    print(stack)
    end
  end
#  println("⇒ Final stack")
end

## Testing part
include("temp.jl")

end ### of CompressedStacks module
