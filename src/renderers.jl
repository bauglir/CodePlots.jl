module Renderers

import Base: show

using HTTP: get

using ..CodePlots: MemberMap

struct PlantUML
  content::AbstractString
end

getModuleMember(m::Module) = (member_name::Symbol) -> getfield(m, member_name)

PlantUML(!Matched::AbstractString) = "Unrenderable"

function PlantUML(m::Module)
  available_members = names(m, all = true)

  members_to_include = filter(
    # The set of available members contains a reference to the containing
    # module itself. This reference needs to be removed from the set of members
    # to prevent an infinite recursion
    member -> member !== m, available_members
  )

  @show members = map(
    member_id -> PlantUML(getfield(m, member_id)), members_to_include
  )

  PlantUML("package $m {\n$(1)\n}")
end

# PlantUML(cmdt::MemberMap{DataType}) = PlantUML(
  # "class $(cmdt.name) << (S, #00cccc) >>"
# )
# PlantUML(cmf::MemberMap{Function}) = PlantUML(
  # "class $(cmf.name) << (F, #cccc00) >>"
# )
# PlantUML(cmm::MemberMap{Module}) = PlantUML(
  # "package $(cmm.name) {\n$(PlantUML(cmm.members).content)\n}"
# )
# PlantUML(vcm::Vector{MemberMap}) = PlantUML(
  # join(map(cm -> PlantUML(cm).content, vcm), '\n')
# )

# Make sure the stringified hex representation is always at least 2 digits
# long, otherwise the encoding will not be interpreted correctly by PlantUML
HexPayload(source::PlantUML) = "-hex-" *
  join(string.(Vector{UInt8}(source.content), base=16, pad=2))

function render(diagram::PlantUML, format::Symbol)
  address = join(
    [ "http://www.plantuml.com/plantuml", format, HexPayload(diagram) ], '/'
  )
  response = get(address)
  response.body
end

# The text/plain MIME type is the general fallback and should be defined
# without an explicit dispatch on the MIME type
show(io::IO, diagram::PlantUML) = write(io, render(diagram, :txt))

show(io::IO, ::MIME"image/png", diagram::PlantUML) =
  write(io, render(diagram, :png))

show(io::IO, ::MIME"image/svg+xml", diagram::PlantUML) =
  write(io, render(diagram, :svg))

end
