### I/O file for ComrpessedStack


## Import
import Base.print

## print functions
function to_string(p::Pair)
  return "($(p.first),$(p.last))"
end
function to_string(v::Level)
  str = "["
  for (id,p) in enumerate(v)
    if id == 1
      str *= "$(to_string(p))"
    else
      str *= ",$(to_string(p))"
    end
  end
  str *= "]"
  return str
end
function to_string(v::Vector{Level})
  str = "[\t\t\t\t"
  for (id,p) in enumerate(v)
      str *= "\n\t\t\tLevel $id\t\t$(to_string(p))"
  end
  str *= "\n\t\t\t ]"
  return str
end
function to_string(v::Vector{Int})
  str = "["
  for (id,p) in enumerate(v)
    if id == 1
      str *= "$p"
    else
      str *= ",$p"
    end
  end
  str *= "]"
  return str
end

function print(stack::CompressedStack)
  println("Compressed Stack with n=$(stack.size), p=$(stack.space), and h=$(stack.depth)")
  println("\t First:")
  println("\t\t (first) compressed ->")
  println("\t\t\t $(to_string(stack.f_compressed))")
  println("\t\t (first) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(to_string(stack.f_explicit))")
  println("\t Second:")
  println("\t\t (second) compressed ->")
  println("\t\t\t $(to_string(stack.s_compressed))")
  println("\t\t (second) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(to_string(stack.s_explicit))")
  println("\t Compressed tail:")
  println("\t\t\t\t\t$(to_string(stack.compressed))")
end
