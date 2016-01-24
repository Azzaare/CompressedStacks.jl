using CompressedStacks
using Base.Test

# write your own tests here
@test 1 == 1

# IO test
include("temp.jl")

println("Test IO")
io_test()
