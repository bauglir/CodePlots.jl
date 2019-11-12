module Diagrams

struct ChildMapConfig
  exportedOnly::Bool

  ChildMapConfig( ; exportedOnly::Bool = true) = new(exportedOnly)
end

struct ChildMap{T}
  name::AbstractString
  children::Vector{ChildMap}
end

getModuleMember(m::Module) = (child_name::Symbol) -> getfield(m, child_name)
moduleChildCanBeMapped(m::Module) = child -> child !== m && childTypeIsMappable(child)

ChildMap(dt::DataType, config::ChildMapConfig = ChildMapConfig()) =
  ChildMap{DataType}("$dt", [])
ChildMap(f::Function, config::ChildMapConfig = ChildMapConfig()) =
  ChildMap{Function}("$f", [])

function ChildMap(m::Module, config::ChildMapConfig = ChildMapConfig())
  available_children = map(
    getModuleMember(m), names(m; all = !config.exportedOnly)
  )

  mappable_children = filter(moduleChildCanBeMapped(m), available_children)

  ChildMap{Module}(
    "$m", map(child -> ChildMap(child, config), mappable_children)
  )
end

childTypeIsMappable(::Any) = false
childTypeIsMappable(d::DataType) = !any(
  map(prefix -> startswith("$d", prefix), [ "getfield", "typeof" ])
)
childTypeIsMappable(::Module) = true
function childTypeIsMappable(f::Function)
  functionName = "$f"

  # Some functions are always defined within a Module. These should not show up
  # in the output
  functionNameIsInExcludeSet = any(map(
    functionNameToExclude -> functionName === functionNameToExclude,
    ["eval", "include"]
  ))

  # Some functions in a Module are methods of functions and should be ignored
  functionNameIsMethod = match(r"\.#", functionName) !== nothing

  !functionNameIsInExcludeSet && !functionNameIsMethod
end

end
