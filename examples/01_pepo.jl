using GeometryBasics
using Graphs
using LaTeXStrings
using NamedGraphs
using TikzPictures
using GraphTikZ

# PEPO
graph = named_grid((3, 3))
# TTNO
# graph = named_comb_tree((3, 3))

tikz_str = tikz(
  graph;
  vertex_position=v -> Point(3, -3 / √2) * (Point(v) + Point(v[2] / 2, 0)),
  vertex=v -> [L"T_{%$(v[1]),%$(v[2])}", Circle(zero(Point2), 0.6), Vec(0.0, -1.0), Vec(0.0, 1.0)],
  vertex_kwargs=(; fill_color="blue"),
)

tp = TikzPicture(tikz_str)
td = TikzDocument()
push!(td, tp; caption="PEPO")
save(PDF("01_pepo"), td)
