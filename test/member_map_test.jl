module MemberMapTest

using Test: @test, @testset

using CodePlots: MemberMap, MemberMapConfig

include("./support/diagrammables.jl")

@testset "MemberMap" begin
  @testset "for a Module" begin
    @testset "that is empty" begin
      mm = MemberMap(Diagrammables.EmptyModule)

      @test mm isa MemberMap{Module}
      @test endswith(mm.name, ".EmptyModule")
    end

    @testset "containing exported function" begin
      mm = MemberMap(Diagrammables.ModuleWithExportedFunction)

      # The module exports a single function
      @test length(mm.members) === 1
      @test mm.members[1] isa MemberMap{Function}
      @test endswith(mm.members[1].name, "exportedFunction")
    end

    @testset "containing exported submodules" begin
      mm = MemberMap(Diagrammables.ModuleWithExportedSubModules)

      @test mm isa MemberMap{Module}
      @test endswith(mm.name, ".ModuleWithExportedSubModules")

      # The module exports two submodules
      @test length(mm.members) === 2

      @testset "submodule $child" for child in mm.members
        member_name = split(child.name, '.') |> pop!
        @test startswith(member_name, "Submodule")
      end
    end

    @testset "containing exported type" begin
      mm = MemberMap(Diagrammables.ModuleWithExportedType)

      # The module exports two types, one abstract and one concrete
      @test length(mm.members) === 2

      @test mm.members[1] isa MemberMap{DataType}
      @test endswith(mm.members[1].name, "ExportedAbstractType")

      @test mm.members[2] isa MemberMap{DataType}
      @test endswith(mm.members[2].name, "ExportedType")
    end

    @testset "containing unexported types" begin
      mm = MemberMap(
        Diagrammables.ModuleWithUnexportedType,
        MemberMapConfig(exportedOnly = false)
      )

      # The module contains two types, one abstract and one concrete. Only
      # types and functions defined in code should be present in the
      # representation.
      @test length(mm.members) === 2

      @test mm.members[1] isa MemberMap{DataType}
      @test endswith(mm.members[1].name, "UnexportedAbstractType")

      @test mm.members[2] isa MemberMap{DataType}
      @test endswith(mm.members[2].name, "UnexportedType")
    end
  end
end

end
