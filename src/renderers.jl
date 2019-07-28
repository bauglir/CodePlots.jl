module Renderers

import Base: show

using HTTP: get

struct PlantUML
  content::AbstractString
end

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
