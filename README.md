# CompressedStacks

[![Build Status](https://travis-ci.org/azzaare/CompressedStacks.jl.svg?branch=master)](https://travis-ci.org/azzaare/CompressedStacks.jl)

The documentation is still in progress (so is the package).

CompressedStacks.jl is a Julia package that provides a framework for compressed stacks. The design of this package is based on the article of ...
All data structures and algorithms are implemented in *pure Julia*, and thus they are portable.

### Main Features

The compressed stack structure used in *CompressedStacks.jl* requires conditions to be used optimally. If implemented with a classical stack, the problem requirements should be as follows:
* The input is read sequentially and only once (in practice we require the user to read input from a file)
* The reading of the stack can be written as below
```
1 : Initialize stack and auxiliary data structure DS with O(1) elements from I
2 : for all subsequent input a ∈ I do
3 :    while pop-condition(a,DS,stack.top(1),. . . , stack.top(k)) do
4 :      stack.pop
5 :    end while
6 :    if push-condition(a,DS,stack.top(1),. . . , stack.top(k)) then
7 :      stack.push(a)
8 :    end if
9 : end for
10: Report(stack)
```
* The user is required to give the following functions (even for classical stacks)
  - pop_condition as in line 3 [return Bool]
  - push_condition as in line 6 [return Bool]
  - pop_action! to do when an element is popped (line 4) [return void]
  - push_action! to when an element is pushed (line 7) [return void]
  - read_input (line 2) [return D, where D is the data_type of the stack]

* For Compressed Stacks, the following parameters are also required
  - (expected) size of the input or depth of the compressed stack
  - maximum space usage or space order
  - buffer of the stack (number of elements of the top than can be accessed anytime)
  - optional data_structure
  - context and data types



