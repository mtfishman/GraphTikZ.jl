using GraphTikZ
using Documenter

DocMeta.setdocmeta!(GraphTikZ, :DocTestSetup, :(using GraphTikZ); recursive=true)

makedocs(;
  modules=[GraphTikZ],
  authors="Matthew Fishman <mfishman@flatironinstitute.org> and contributors",
  repo="https://github.com/mtfishman/GraphTikZ.jl/blob/{commit}{path}#{line}",
  sitename="GraphTikZ.jl",
  format=Documenter.HTML(;
    prettyurls=get(ENV, "CI", "false") == "true",
    canonical="https://mtfishman.github.io/GraphTikZ.jl",
    edit_link="main",
    assets=String[],
  ),
  pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/mtfishman/GraphTikZ.jl", devbranch="main")
