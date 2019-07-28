module Diagrams

struct ChildMap{T}
  name::AbstractString
end

function ChildMap(m::Module)
  ChildMap{Module}("$m")
end

end
