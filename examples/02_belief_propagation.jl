using DataGraphs
using GeometryBasics
using Graphs
using GraphTikZ
using LaTeXStrings
using LinearAlgebra
using NamedGraphs
using NetworkLayout
using TikzPictures

n = 6
path_g = path_graph(n)
g = random_regular_graph(n, 3)

shape = Rect(Vec(-0.5, -0.5), Vec(1.0, 1.0))

td = TikzDocument()

lines = [
  Vec(0.0, -1.0),
  Vec(-1.0, 0.0),
  Vec(1.0, 0.0),
]
tikz_str = tikz(
  [lines; shape];
  text=L"T_j",
  fill_color="blue",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS tensor")

lines = [
  Vec(0.0, -1.0),
  Vec(-1.0, 1.0),
  Vec(-1.0, -1.0),
  Vec(1.0, 0.0),
]
lines[2:end] .*= √2 ./ norm.(lines[2:end])
tikz_str = tikz(
  [lines; shape];
  text=L"T_j",
  fill_color="blue",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Tensor")

tikz_str = tikz(
  path_g;
  shape=[Vec(0.0, -1.0), shape],
  fill_color="blue",
  text=v -> L"T_{%$(v)}",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS")

tikz_str = tikz(
  path_g;
  position=v -> 1.5 * GraphTikZ.default_position(v),
  shape=[Vec(0.0, -1.0), shape],
  fill_color="blue",
  text=v -> L"T_{%$(v)}",
  edge_shape=Circle(zero(Point2), 0.4),
  edge_fill_color="orange",
  edge_text=e -> L"\lambda_{%$(src(e))\leftrightarrow %$(dst(e))}",
  edge_text_size="\\small",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS Vidal gauge")

positions = spring(g)
tikz_str = tikz(
  g;
  position=(v -> 2positions[v]),
  shape=[Vec(0.0, -1.0), shape],
  fill_color=v -> rand(["blue", "yellow", "red"]),
  text=v -> L"T_{%$(v)}",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="TN")

tikz_str = tikz(
  g;
  position=(v -> 2positions[v]),
  shape=[Vec(0.0, -1.0), shape],
  fill_color=v -> rand(["blue", "yellow", "red"]),
  text=v -> L"T_{%$(v)}",
  edge_shape=Circle(zero(Point2), 0.4),
  edge_fill_color="orange",
  edge_text=e -> L"\lambda_{%$(src(e))\leftrightarrow %$(dst(e))}",
  edge_text_size="\\small",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="TN Vidal gauge")

path_gg = path_g ⊔ path_g
for v in vertices(path_g)
  add_edge!(path_gg, (v, 1) => (v, 2))
end
tikz_str = tikz(
  path_gg;
  text=v -> v[2] == 2 ? L"T_{%$(v[1])}" : L"T^*_{%$(v[1])}",
  fill_color=v -> v[2] == 2 ? "blue" : "red",
  shape,
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS inner")

gg = g ⊔ g
for v in vertices(g)
  add_edge!(gg, (v, 1) => (v, 2))
end
tikz_str = tikz(
  gg;
  position=v -> v[2] == 2 ? 2positions[v[1]] : 2positions[v[1]] - Point(0.0, 1.5),
  text=v -> v[2] == 2 ? L"T_{%$(v[1])}" : L"T^*_{%$(v[1])}",
  fill_color=v -> v[2] == 2 ? "blue" : "red",
  shape,
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="TN inner")

minus1(j::Integer) = j - 1
plus1(j::Integer) = j + 1
minus1(j::String) = "$(j)-1"
plus1(j::String) = "$(j)+1"

function message_tensor_tikz(
  j;
  start_position=zero(Point2),
  message_tensor_text_size=GraphTikZ.default_text_size(),
  shape=GraphTikZ.default_shape(),
)
  lines = [
    LineString([Point(0.0, 0.0), Point(0.0, -1.0), Point(1.0, -1.0)]),
    LineString([Point(0.0, 0.0), Point(0.0, 1.0), Point(1.0, 1.0)]),
  ]

  tikz_str = tikz(;
    text=L"M_{%$(minus1(j))\rightarrow %$(j)}",
    position=start_position + Point(0.0, -1.0),
    shape=[lines; shape],
    fill_color="red",
    text_size=message_tensor_text_size,
  )

  g = path_graph(1)
  gg = g ⊔ g
  for v in vertices(g)
    add_edge!(gg, (v, 1) => (v, 2))
  end
  tikz_str *= tikz(
    gg;
    position=v -> start_position + 2(Point(v) - Point(0.0, 2.0)),
    text=v -> v[2] == 2 ? L"T_{%$(j)}" : L"T^*_{%$(j)}",
    shape=[Vec(-1.0, 0.0), Vec(1.0, 0.0), shape],
    fill_color="blue",
  )

  tikz_str *= tikz(; text=L"=", position=start_position + Point(4.0, -1.0))
  tikz_str *= tikz(; text=L"\lambda_{%$(j)}", position=start_position + Point(5.0, -1.0))

  # TODO: Pass `shape` as the first argument!
  tikz_str *= tikz(;
    text=L"M_{%$(j)\rightarrow %$(plus1(j))}",
    position=start_position + Point(6.0, -1.0),
    shape=[lines; shape],
    fill_color="red",
    text_size=message_tensor_text_size,
  )
  return tikz_str
end

tikz_str = message_tensor_tikz(2; shape)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="BP message tensor update")

tikz_str = message_tensor_tikz(
  "j";
  shape,
  message_tensor_text_size="\\tiny",
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="BP message tensor update")

save(PDF("02_belief_propagation"), td)
