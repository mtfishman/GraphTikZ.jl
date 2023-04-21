using DataGraphs
using GeometryBasics
using Graphs
using GraphTikZ
using LaTeXStrings
using LinearAlgebra
using NamedGraphs
using NetworkLayout
using Statistics
using TikzPictures

using GraphTikZ: translate, rotate

n = 6
path_g = path_graph(n)
g = random_regular_graph(n, 3)

shape = Rect(Vec(-0.5, -0.5), Vec(1.0, 1.0))
shape_alt = Polygon([Point2(-0.5, -0.5), Point2(-0.5, 0.5), Point2(0.5, 0.5), Point2(0.5, -0.5)])

td = TikzDocument()

tikz_str = tikz(; vertex=shape)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor")

tikz_str = tikz(; vertex=rotate(shape, π / 3))
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor rotated")

tikz_str = tikz(; vertex=rotate(shape, π / 8; center=Point(-10.0, -10.0)))
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor rotated about a center")

tikz_str = tikz(;
  vertex=shape_alt,
  vertex_kwargs=(; corner_roundness=10),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor custom corner rounding")

tikz_str = tikz(;
  vertex=shape_alt,
  vertex_kwargs=(; corner_roundness=[2, 5, 8, 15]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor corner-specific rounding")

tikz_str = tikz(;
  vertex=shape_alt,
  vertex_kwargs=(; corner_roundness=[2, 14, 14, 2]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor semistadium")

tikz_str = tikz(;
  vertex=rotate(shape_alt, π / 4),
  vertex_kwargs=(; corner_roundness=[2, 14, 14, 2]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor semistadium rotated")

tikz_str = tikz(;
  vertex=LineString([Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 0.0), Point(1.0, -1.0)]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Lines")

tikz_str = tikz(;
  vertex=LineString([Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 0.0), Point(1.0, -1.0)]),
  vertex_kwargs=(; corner_roundness=0),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Lines, no rounding")

tikz_str = tikz(;
  vertex=LineString([Point(0.0, 0.0), Point(1.0, 1.0), Point(2.0, 0.0), Point(1.0, -1.0)]),
  vertex_kwargs=(; corner_roundness=[5, 14]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Lines with custom corner roundness")

tikz_str = tikz(Graph(2);
  vertex=[shape_alt, shape_alt],
  vertex_kwargs=(; corner_roundness=[2, 14, 14, 2]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Two order 0 tensors")

tikz_str = tikz(Graph(2);
  vertex=v -> [shape_alt, shape_alt][v],
  vertex_kwargs=v -> [(; corner_roundness=[2, 14, 14, 2]), (; corner_roundness=[2, 14, 2, 14])][v],
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Two order 0 tensors, specify different options")

tikz_str = tikz(;
  vertex=[
    meta(shape_alt; corner_roundness=[2, 14, 14, 2], fill_color="blue"),
    meta(translate(shape_alt, Point(2.0, 0.0)); corner_roundness=[2, 14, 2, 14], fill_color="orange"),
  ],
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Two order 0 tensors, specify different options through metadata")

tikz_str = tikz(; vertex=[L"T_j", shape_alt])
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Order 0 tensor with label")

lines = [Vec(0.0, -1.0), Vec(-1.0, 0.0), Vec(1.0, 0.0)]
tikz_str = tikz(; vertex=[[L"T_j", shape]; lines])
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS tensor 1")

tikz_str = tikz(;
  vertex=[[L"T_j", shape]; lines],
  vertex_kwargs=(; fill_color="blue", line_color="red", text_color="white"),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS tensor 2")

tikz_str = tikz(;
  vertex=[[L"T_j", shape]; lines],
  vertex_kwargs=[(; text_color="white"), (; fill_color="blue", line_color="brown")],
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS tensor 3")

lines = [Vec(0.0, -1.0), Vec(-1.0, 1.0), Vec(-1.0, -1.0), Vec(1.0, 0.0)]
lines[2:end] .*= √2 ./ norm.(lines[2:end])
tikz_str = tikz(; vertex=[[L"T_j", shape]; lines], vertex_kwargs=(; fill_color="blue"))
tp = TikzPicture(tikz_str)
push!(td, tp; caption="Tensor")

tikz_str = tikz(path_g; vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)])
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 1")

tikz_str = tikz(
  path_g;
  vertex_position=v -> 2Point(v),
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  vertex_kwargs=(; fill_color="blue", line_color="red", text_color="white"),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 2")

tikz_str = tikz(
  path_g;
  vertex_position=v -> isodd(v) ? 2Point(v, 0.0) : 2Point(v, 0.0) + Point(0.0, 1.0),
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  vertex_kwargs=(; fill_color="blue", line_color="red", text_color="white"),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 3")

vertex = function (v)
  return [
    iseven(v) ? meta(Point(0.0, 1.0); text=L"T_{%$(v)}") : L"T_{%$(v)}",
    shape,
    isodd(v) ? Vec(0.0, -1.0) : 2Vec(0.0, -1.0),
  ]
end
vertex_kwargs = function (v)
  return [
    (; text_color=isodd(v) ? "yellow" : "black"),
    (; fill_color="blue", line_color=isodd(v) ? "red" : "orange"),
    (; line_color=isodd(v) ? "black" : "blue"),
  ]
end
tikz_str = tikz(path_g; vertex, vertex_kwargs)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 4")

tikz_str = tikz(path_g; vertex, vertex_kwargs)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 5")

text = function (e)
  return function (p1, p2)
    return meta(
      Point(mean((p1, p2)) + Point(0.0, 0.5));
      text=L"e_{%$(src(e))\leftrightarrow %$(dst(e))}",
    )
  end
end
edge = function (e)
  return [text(e), Line]
end
tikz_str = tikz(path_g; vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)], edge)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 6")

tikz_str = tikz(
  path_g;
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  edge=e -> (p1, p2) -> LineString([p1, mean((p1, p2)) + Point(0.0, 1.0), p2]),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 7")

tikz_str = tikz(
  path_g;
  vertex_position=v -> 3Point(v, 0.0),
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  edge=Circle(zero(Point2), 0.3),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 8")

vertex = function (v)
  return [L"T_{%$(v)}", shape, Vec(0.0, -1.0)]
end
vertex_kwargs = function (v)
  return [
    (; text_color="white"),
    (; fill_color="blue", line_color="purple"),
    (; line_color="gray"),
  ]
end
edge = function (e)
  return [L"\lambda_{%$(src(e))\leftrightarrow %$(dst(e))}", Circle(zero(Point2), 0.4), Line]
end
edge_kwargs = function (e)
  return [
    (; text_size="\\tiny"),
    (; fill_color="blue", line_color="green"),
    (; line_color="orange"),
  ]
end
tikz_str = tikz(
  path_g; vertex_position=v -> 3Point(v, 0.0), vertex, vertex_kwargs, edge, edge_kwargs
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS 9")

positions = spring(g)
tikz_str = tikz(
  g;
  vertex_position=(v -> 2positions[v]),
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  vertex_kwargs=v -> (; fill_color=rand(["blue", "yellow", "red"])),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="TN 1")

tikz_str = tikz(
  g;
  vertex_position=(v -> 2positions[v]),
  vertex=v -> [L"T_{%$(v)}", shape, Vec(0.0, -1.0)],
  vertex_kwargs=v -> (; fill_color=rand(["blue", "yellow", "red"])),
  edge=e ->
    [L"\lambda_{%$(src(e))\leftrightarrow %$(dst(e))}", Circle(zero(Point2), 0.4), Line],
  edge_kwargs=[(; text_size="\\small"), (; fill_color="orange")],
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="TN 2")

path_gg = path_g ⊔ path_g
for v in vertices(path_g)
  add_edge!(path_gg, (v, 1) => (v, 2))
end
tikz_str = tikz(
  path_gg;
  vertex=v -> [iseven(v[2]) ? L"T_{%$(v[1])}" : L"T^*_{%$(v[1])}", shape],
  vertex_kwargs=v -> (; fill_color=iseven(v[2]) ? "blue" : "red"),
)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="MPS inner")

gg = g ⊔ g
for v in vertices(g)
  add_edge!(gg, (v, 1) => (v, 2))
end
tikz_str = tikz(
  gg;
  vertex_position=v -> iseven(v[2]) ? 2positions[v[1]] : 2positions[v[1]] - Point(0.0, 1.5),
  vertex=v -> [iseven(v[2]) ? L"T_{%$(v[1])}" : L"T^*_{%$(v[1])}", shape],
  vertex_kwargs=v -> (; fill_color=iseven(v[2]) ? "blue" : "red"),
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
    vertex_position=start_position + Point(0.0, -1.0),
    vertex=[L"M_{%$(minus1(j))\rightarrow %$(j)}"; shape; lines],
    vertex_kwargs=(; fill_color="red", text_size=message_tensor_text_size),
  )

  g = path_graph(1)
  gg = g ⊔ g
  for v in vertices(g)
    add_edge!(gg, (v, 1) => (v, 2))
  end
  vertex = function (v)
    return [
      iseven(v[2]) ? L"T_{%$(j)}" : L"T^*_{%$(j)}", shape, Vec(-1.0, 0.0), Vec(1.0, 0.0)
    ]
  end
  tikz_str *= tikz(
    gg;
    vertex_position=v -> start_position + 2(Point(v) - Point(0.0, 2.0)),
    vertex,
    vertex_kwargs=(; fill_color="blue"),
  )

  tikz_str *= tikz(; vertex_position=start_position + Point(4.0, -1.0), vertex=L"=")
  tikz_str *= tikz(;
    vertex_position=start_position + Point(5.0, -1.0), vertex=L"\lambda_{%$(j)}"
  )

  tikz_str *= tikz(;
    vertex=[L"M_{%$(j)\rightarrow %$(plus1(j))}"; shape; lines],
    vertex_position=start_position + Point(6.0, -1.0),
    vertex_kwargs=(; fill_color="red", text_size=message_tensor_text_size),
  )
  return tikz_str
end

tikz_str = message_tensor_tikz(2; shape)
tp = TikzPicture(tikz_str)
push!(td, tp; caption="BP message tensor update")

tikz_str = message_tensor_tikz("j"; shape, message_tensor_text_size="\\tiny")
tp = TikzPicture(tikz_str)
push!(td, tp; caption="BP message tensor update")

save(PDF("02_belief_propagation"), td)
