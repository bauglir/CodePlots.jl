module PlantUMLTest

using Test: @testset

@testset "PlantUML" begin
  include("./render_test.jl")
end

end
