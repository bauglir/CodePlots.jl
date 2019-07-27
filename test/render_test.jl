module RenderTest

using Test: @testset, @test

using CodePlots: Diagram

@testset "rendering" begin
  diagram = Diagram("Bob -> Alice : Hello")

  @testset "to ASCII" begin
    buffer = IOBuffer()
    expected_render = String(read(joinpath(@__DIR__, "renders", "bob-hello-alice.txt")))

    show(buffer, diagram)
    # The rendered version may contain trailing whitespace, which has been
    # removed from the stored renders so needs to be removed here as well
    actual_render = replace(String(take!(buffer)), r"\s+\n" => '\n')

    @test actual_render == expected_render
  end

  @testset "to PNG" begin
    buffer = IOBuffer()
    expected_render = read(joinpath(@__DIR__, "renders", "bob-hello-alice.png"))

    show(buffer, MIME("image/png"), diagram)
    actual_render = take!(buffer)

    @test actual_render == expected_render
  end

  @testset "to SVG" begin
    buffer = IOBuffer()
    expected_render = String(read(joinpath(@__DIR__, "renders", "bob-hello-alice.svg")))

    show(buffer, MIME("image/svg+xml"), diagram)
    # The rendered version uses CRLF line-endings and information about the
    # PlantUML server that rendered it. The prerendered version only has LF as
    # enforced by Git and removed the server information as that is likely to
    # change over time and shouldn't break tests. The rendered version needs
    # these stripped
    actual_render = replace(String(take!(buffer)), r"\r\n" => '\n')
    actual_render = replace(actual_render , r"@enduml.+?</g>"s => "@enduml\n--></g>")

    @test actual_render == expected_render
  end
end

end
