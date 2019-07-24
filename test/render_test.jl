module RenderTest

using Test: @testset, @test

using PlantUML: Diagram

@testset "rendering" begin
  @testset "to ASCII" begin
    diagram = Diagram("Bob -> Alice : Hello")

    buffer = IOBuffer()
    expected_render = String(read(joinpath(@__DIR__, "renders", "bob-hello-alice.txt")))

    show(buffer, diagram)
    # The rendered version may contain trailing whitespace, which has been
    # removed from the stored renders so needs to be removed here as well
    actual_render = replace(String(take!(buffer)), r"\s+\n" => '\n')

    @test actual_render == expected_render
  end
end

end
