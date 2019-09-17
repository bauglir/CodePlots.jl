module Diagrams

struct ChildMap{T}
  name::AbstractString
  children::Vector{ChildMap}
end

getModuleMember(m::Module) = (child_name::Symbol) -> getfield(m, child_name)
moduleChildCanBeMapped(m::Module) = child -> child !== m

function ChildMap(m::Module)
  available_children = map(getModuleMember(m), names(m))

  mappable_children = filter(moduleChildCanBeMapped(m), available_children)

  ChildMap{Module}("$m", map(ChildMap, mappable_children))
end

end
