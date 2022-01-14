module Diagrams

const FOOBAR = "I'm a constant..."

macro bar(expr::Expr)
  expr
end

struct MemberMapConfig
  exportedOnly::Bool

  MemberMapConfig( ; exportedOnly::Bool = true) = new(exportedOnly)
end

struct MemberMap{T}
  name::AbstractString
  members::Vector
end

# Even though a name is exported doesn't mean it is actually defined requiring
# an explicit check before retrieving the member
# getModuleMember(m::Module) = (member_name::Symbol) -> isdefined(m, member_name) && getfield(m, member_name)
getModuleMember(m::Module) = (member_name::Symbol) -> getfield(m, member_name)

function MemberMap(m::Module, config::MemberMapConfig = MemberMapConfig())
  available_members = map(
    getModuleMember(m), names(m; all = !config.exportedOnly)
  )

  members_to_include = filter(
    # The set of available members contains a reference to the containing
    # module itself. This reference needs to be removed from the set of members
    # to prevent an infinite recursion
    member -> member !== m && includeInMemberMap(member), available_members
  )

  recursively_mapped_members = map(
    member -> MemberMap(member, config),
    filter(isMemberMappable, members_to_include)
  )

  MemberMap{Module}(
    "$m", vcat(members_to_include, recursively_mapped_members)
  )
end

includeInMemberMap(::Any) = true
includeInMemberMap(d::DataType) = !any(
  map(prefix -> startswith("$d", prefix), [ "getfield", "typeof" ])
)
function includeInMemberMap(f::Function)
  functionName = "$f"

  # Some functions are always defined within a Module. These should not show up
  # in the output
  functionNameIsInExcludeSet = any(map(
    functionNameToExclude -> functionName === functionNameToExclude,
    ["eval", "include"]
  ))

  # THIS CHECK IS NO LONGER NECESSARY? THIS APPARENTLY GETS CAUGHT BY THE
  # DEFAULT CASE OF isMemberMappable!
  # Some functions in a Module are methods of functions and should be ignored
  # functionNameIsMethod = match(r"\.#", functionName) !== nothing

  !functionNameIsInExcludeSet# && !functionNameIsMethod
end

isMemberMappable(::Any) = false
isMemberMappable(::Module) = true

end
