using GraphTikZ
using Test

@testset "GraphTikZ.jl" begin
  include(joinpath(pkgdir(GraphTikZ), "examples", "01_example.jl"))
end
