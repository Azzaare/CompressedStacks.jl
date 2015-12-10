using CompressedStacks
using Base.Test

# write your own tests here
@test 1 == 1

# Constructor test
import CompressedStacks.stack_test, CompressedStacks.push_test
stack_test(81,3)

println("\n\n Push Test")
push_test(81,3)
