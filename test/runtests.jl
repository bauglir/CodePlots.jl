module CodePlotsTest

using Test: @testset

@testset "CodePlots" begin
  include("./member_map_test.jl")
  include("./render_test.jl")
end

end
