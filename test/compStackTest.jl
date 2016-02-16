using CompressedStacks

#import CompressedStacks.stack_test
import CompressedStacks.CompressedStack
#import CompressedStacks.access
#import CompressedStacks.run!

#stack_test(70,3)

#original benchmark function
#function benchmark()
    # Any setup code goes here.

    # Run once, to force compilation.
#    srand(666)
#    @time code_to_profile()

    # Run a second time, with profiling.
#    println("\n\n======================= Second run:")
#    srand(666)
#    Profile.init(delay=0.01)
#    clear_malloc_data()
#    @profile @time code_to_profile()

    # Write profile results to profile.bin.
#    r = Profile.retrieve()
#    f = open("profile.bin", "w")
#    serialize(f, r)
#    close(f)
#end

function printsum(a)
    # summary generates a summary of an object
    println(summary(a), ": ", repr(a))
end

function condition_push(stack::CompressedStack, elt::Int)

return true

end

function condition_pop(stack::CompressedStack, elt::Int)

  #println("La lio? ",isempty(stack))
  # This sort of reads the next one?
    if !isempty(stack)
      popRatio= parse(ARGS[3])
      min=parse(ARGS[4])
      max=parse(ARGS[5])
      range=max-min
      topElement=top(stack)

    #flush(STDOUT)
    #  println("should I POP ",aux[1]," ? : ",(parse(aux[1]) < (min+popRatio*range)))
    #flush(STDOUT)
        if (elt==(max+1))
          #println("POPPOP")
          return true
        else
          return ( (elt+topElement) < (min+2*popRatio*range))
        end
    else
        print(stack)
        println("IN this case the compressed stack was empty so I should NOT pop, unless I am comparing the run! of two stacks")
        return false
    end

end

function action_push(stack::CompressedStack{Int,Int}, elt::Int)
  stack.context = Nullable(stack.index)
  # print(stack)
end

function action_pop(stack::CompressedStack, elt::Int)
#  println("Pop element : $elt")
end


#now do the same thing again for the normal stack

function condition_push2(stack::NormalStack, elt::Int)
#  aux = elt

#  popRatio= parse(ARGS[3])
#  min=parse(ARGS[4])
#  max=parse(ARGS[5])
#  range=max-min
#  return (aux > (min+popRatio*range))
  return true
end

function condition_pop2(stack::NormalStack, elt::Int)
#println("La lio? ",isempty(stack))
# This sort of reads the next one?
  if !isempty(stack)
    popRatio= parse(ARGS[3])
    min=parse(ARGS[4])
    max=parse(ARGS[5])
    range=max-min
    topElement=top(stack)

  #flush(STDOUT)
  #  println("should I POP ",aux[1]," ? : ",(parse(aux[1]) < (min+popRatio*range)))
  #flush(STDOUT)
      if (elt==(max+1))
          #println("POPPOP")
          return true
      else
        return ( (elt+topElement) < (min+2*popRatio*range))
      end

  else
      print(stack)
      println("IN this case the normal stack was empty so I should NOT pop, unless I am comparing the run! of two stacks")
      return false
  end

end

function action_push2(stack::NormalStack{Int,Int}, elt::Int)
  stack.context = Nullable(stack.index)
  # print(stack)
end

function action_pop2(stack::NormalStack, elt::Int)
#  println("Pop element : $elt")
end



function randomPushPopTestCompressed(name,size,space)

  println("randomPushPopTest with compressed stack, with Parameters size:",size," space: ",space," name ",name)

  context_type = Int
  data_type = Int


  #ns = NormalStack(name, action_pop2, action_push2, condition_pop2,
  #condition_push2, context_type, data_type)

  #cs = CompressedStack(name, action_pop, action_push, condition_pop,
  #condition_push, context_type, data_type)


  stack = CompressedStack(name, action_pop, action_push, condition_pop, condition_push, context_type, data_type,size,space)
 normalstack = NormalStack(name, action_pop2, action_push2, condition_pop2, condition_push2, context_type, data_type)

#println("Running ")
#try run!(stack,normalstack)
#try  run!(stack)
#try run!(normalstack)
#catch Exception e
#  println("Yagos code caught this exception ",e)
#  println("The stack was ")
#  print(stack)
#end

# seekend(stack.input)
# seekend(normalstack.input)
# println(position(stack.input)==position(normalstack.input))

run!(stack,normalstack)
#run!(stack)

  stack = 0

end

#function randomPushPopTest(repetitions,popRatio,min,max)
function randomPushPopTest(name)

# First let us make a normal stack
#q=Int[]
#println("randomPushPopTest, Parameters ",repetitions," ",popRatio," ",min," ",max," ")
#range=max-min
# Careful, as the rand is of integers this is not really working as a random choice with popRatio parameter
#for i = 1:repetitions
#  (x=rand(min:max)) > (min+popRatio*range) ? push!(q,x) : isempty(q) ? true : pop!(q)
  #println(i)
#end

println("randomPushPopTest with normal stack, with Parameters name:",name)

context_type = Int
data_type = Int

#ns = NormalStack(name, action_pop2, action_push2, condition_pop2,
#condition_push2, context_type, data_type)

#cs = CompressedStack(name, action_pop, action_push, condition_pop,
#condition_push, context_type, data_type)

#stack = CompressedStack(name, action_pop, action_push, condition_pop, condition_push, context_type, data_type,size,space)
normalstack = NormalStack(name, action_pop2, action_push2, condition_pop2, condition_push2, context_type, data_type)

run!(normalstack)
#try run!(normalstack)
#catch Exception e
#  println("normal stack caught this exception ",e)
#  println("The stack was ")
#  print(normalstack)
#end

normalstack = 0







end

#printsum(q)
if (isempty(ARGS) || length(ARGS)<8) println("WRONG PARAMETERS! NEED 5 (repetitions popRatio min max n p testType(0 normal 1 compressed) )")
else


  IOFileName=ARGS[1]
  size=parse(ARGS[2])
  min=parse(ARGS[4])
  max=parse(ARGS[5])
  n=parse(ARGS[6])
  p=parse(ARGS[7])


   println("Testing : FileName ",IOFileName,"\n repetitions: ",size," popRatio  ",ARGS[3]," min ",min,"  max ",max,"  n ",n," p ",p," testType(0 normal 1 compressed) ",ARGS[8])


    # Run once, to force compilation.
  #println("======================= First run:")
  #srand(666)
  #@time parse(ARGS[8])==0 ? randomPushPopTest(10,0.1,1,5) : randomPushPopTestCompressed("/home/yago/.julia/v0.4/CompressedStacks/ioexample/input1")

  # Run a second time, with profiling.
  #println("\n\n======================= Second run:")
  srand(666)

  Profile.init(delay=0.01)
  Profile.clear()

  Profile.clear_malloc_data()
  gc()
  #@profile @time parse(ARGS[8])==0 ? randomPushPopTest(parse(ARGS[2]),parse(ARGS[3]),parse(ARGS[4]),parse(ARGS[5])) : randomPushPopTestCompressed(IOFileName)
#parse(ARGS[8])==0 ? randomPushPopTest(parse(ARGS[2]),parse(ARGS[3]),parse(ARGS[4]),parse(ARGS[5])) : randomPushPopTestCompressed(IOFileName,n,p)
parse(ARGS[8])==0 ? randomPushPopTest( IOFileName ) : randomPushPopTestCompressed(IOFileName,n,p)


  # Write profile results to profile.bin.
#  r = Profile.retrieve()
#  f = open("profile.bin", "w")
#  serialize(f, r)
#  close(f)

end
