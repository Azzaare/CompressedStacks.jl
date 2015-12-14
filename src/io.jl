### I/O file for ComrpessedStack


## Import
import Base.print, Base.string

## convert functions
function string{T}(p::Nullable{T})
  if !isnull(p)
    str = string(get(p))
  else
    str = "∅"
  end
  return str
end
function string{T}(p::Nullable{ExtPair{T}})
  if !isnull(p)
    str = string(get(p))
  else
    str = "∅"
  end
  return str
end
function string{T}(p::ExtPair{T})
  return "($(p.first),$(p.last)) <- $(p.context)"
end
function string{T}(v::Block{T})
  str = "["
  for (id,p) in enumerate(v)
    if id == 1
      str *= "$(string(p))"
    else
      str *= ",$(string(p))"
    end
  end
  str *= "]"
  return str
end
function string{T}(v::Levels{T})
  str = "[\t\t\t\t"
  for (id,p) in enumerate(v)
      str *= "\n\t\t\tLevel $id\t\t$(string(p))"
  end
  str *= "\n\t\t\t ]"
  return str
end
function string(v::Vector{Int})
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

function print{T}(stack::CompressedStack{T})
  println("Compressed Stack with n=$(stack.size), p=$(stack.space), and h=$(stack.depth)")
  println("\t First:")
  println("\t\t (first) compressed ->")
  println("\t\t\t $(string(stack.f_compressed))")
  println("\t\t (first) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(string(stack.f_explicit))")
  println("\t Second:")
  println("\t\t (second) compressed ->")
  println("\t\t\t $(string(stack.s_compressed))")
  println("\t\t (second) explicit ->")
  println("\t\t\tLevel $(stack.depth)\t\t$(string(stack.s_explicit))")
  println("\t Compressed tail:")
  println("\t\t\t\t\t$(string(stack.compressed))\n")
  println("\t Context:")
  println("\t\t\t\t\t$(string(stack.context))\n")
end
