using GraphTikZ
using Test

@testset "GraphTikZ.jl" begin
  examples_path = joinpath(pkgdir(GraphTikZ), "examples")
  include(joinpath(examples_path, "01_pepo.jl"))
  include(joinpath(examples_path, "02_belief_propagation.jl"))
end
