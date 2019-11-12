module Diagrams

struct MemberMapConfig
  exportedOnly::Bool

  MemberMapConfig( ; exportedOnly::Bool = true) = new(exportedOnly)
end

struct MemberMap{T}
  name::AbstractString
  members::Vector{MemberMap}
end

getModuleMember(m::Module) = (member_name::Symbol) -> getfield(m, member_name)
memberCanBeMapped(m::Module) = member -> member !== m && memberIsMappable(member)

MemberMap(dt::DataType, config::MemberMapConfig = MemberMapConfig()) =
  MemberMap{DataType}("$dt", [])
MemberMap(f::Function, config::MemberMapConfig = MemberMapConfig()) =
  MemberMap{Function}("$f", [])

function MemberMap(m::Module, config::MemberMapConfig = MemberMapConfig())
  available_members = map(
    getModuleMember(m), names(m; all = !config.exportedOnly)
  )

  mappable_members = filter(
    # The set of available members contains a reference to the containing
    # module itself. This reference needs to be removed from the set of
    # mappable members to prevent an infinite recursion
    member -> member !== m && memberCanBeMapped(member), available_members
  )

  MemberMap{Module}(
    "$m", map(member -> MemberMap(member, config), mappable_members)
  )
end

memberCanBeMapped(::Any) = false
memberCanBeMapped(d::DataType) = !any(
  map(prefix -> startswith("$d", prefix), [ "getfield", "typeof" ])
)
memberCanBeMapped(::Module) = true
function memberCanBeMapped(f::Function)
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
