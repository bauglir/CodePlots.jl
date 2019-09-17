module ChildMapTest

using Test: @test, @testset

using CodePlots: ChildMap

include("./support/diagrammables.jl")

@testset "ChildMap" begin
  @testset "for a Module" begin
    @testset "that is empty" begin
      cm = ChildMap(Diagrammables.EmptyModule)

      @test cm isa ChildMap{Module}
      @test endswith(cm.name, ".EmptyModule")
    end

    @testset "containing exported submodules" begin
      cm = ChildMap(Diagrammables.ModuleWithExportedSubModules)

      @test cm isa ChildMap{Module}
      @test endswith(cm.name, ".ModuleWithExportedSubModules")

      # The module exports two submodules
      @test length(cm.children) === 2

      @testset "submodule $child" for child in cm.children
        member_name = split(child.name, '.') |> pop!
        @test startswith(member_name, "Submodule")
      end
    end
  end
end

end
