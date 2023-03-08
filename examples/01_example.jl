using GeometryBasics
using Graphs
using LaTeXStrings
using NamedGraphs
using TikzPictures
using GraphTikZ

function main(; graph::AbstractGraph)
  # Add dangling edges to each vertex
  s1 = NamedGraph(DanglingEdge{1}.(vertices(graph)))
  s2 = NamedGraph(DanglingEdge{2}.(vertices(graph)))
  gs = graph ∪ s1 ∪ s2
  for v in vertices(graph)
    add_edge!(gs, v => DanglingEdge{1}(v))
    add_edge!(gs, v => DanglingEdge{2}(v))
  end

  vertex_position(v) = Point(3, -3/√2) * (Point(v) + Point(v[2]/2, 0))
  vertex_position(v::DanglingEdge{1}) = vertex_position(v.vertex) - Point(0, 1)
  vertex_position(v::DanglingEdge{2}) = vertex_position(v.vertex) + Point(0, 1)

  vertex_subscript(v) = "_{$(v[1]),$(v[2])}"

  vertex_label(v, position) = (text=L"T%$(vertex_subscript(v))", position)
  function vertex_label(v::DanglingEdge{1}, position)
    return (text=L"s%$(vertex_subscript(v.vertex))", position=(position - 0.3Point(0, 1)))
  end
  function vertex_label(v::DanglingEdge{2}, position)
    return (text=L"s'%$(vertex_subscript(v.vertex))", position=(position + 0.3Point(0, 1)))
  end

  circle(position) = Circle(position, 0.6)
  square(position) = Rect(Vec(position) - 0.5Vec(1, 1), Vec(position) + 0.5Vec(1, 1))
  function triangle(position)
    coordinates = [
      Point(-0.5, 0),
      Point(0.5, 0),
      Point(0, √3/2),
    ]
    coordinates .-= Point(0, 0.25)
    coordinates *= 1.2
    return Polygon(coordinates .+ position)
  end

  vertex_shape(v, position) = rand((triangle(position), square(position), circle(position)))

  vertex_shape(v::DanglingEdge, position) = position

  vertex_fill_color(v) = rand(["red", "blue", "yellow"])

  return tikz(gs; vertex_position, vertex_shape, vertex_label, vertex_fill_color)
end

graph = named_grid((3, 3))
# graph = named_comb_tree((3, 3))

tp = TikzPicture(main(; graph))
td = TikzDocument()
push!(td, tp; caption="PEPO")
save(PDF("PEPO"), td)
