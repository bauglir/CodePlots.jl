module ChildMapTest

using Test: @test, @testset

using CodePlots: ChildMap

include("./support/diagrammables.jl")

@testset "ChildMap" begin
  @testset "for Module" begin
    cm = ChildMap(Diagrammables.EmptyModule)

    @test cm isa ChildMap{Module}
    @test endswith(cm.name, ".EmptyModule")
  end
end

end
