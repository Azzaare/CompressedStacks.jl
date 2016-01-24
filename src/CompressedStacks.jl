### Julia module for the Compressed Stack structure ###
__precompile__() # Precompile option for the module. Is recompiled after changes
module CompressedStacks

## Import/Export
export CompressedStack, NormalStack, run!

## Basic types and constructors for CompressedStack
include("base.jl")
## NormalStack
include("normal.jl")
## I/O for Stacks structure
include("io.jl")

## Action for Compressed Stack's internals mechanisms
# Basic access, test emptiness, update blocks
include("access.jl")
# Pushes and pops
include("push.jl")
include("pop.jl") # reconstruct.jl is nested in
# Run the stacks
include("run.jl")

## Specialized types of Compressed Stacks

end ### of CompressedStacks module
