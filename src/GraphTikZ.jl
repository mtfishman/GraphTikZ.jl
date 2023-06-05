module GraphTikZ
using Dictionaries
using GeometryBasics
using Graphs
using InfiniteArrays
using LaTeXStrings
using Statistics

export tikz, rotate

to_function(x::Function) = x
to_function(x) = Returns(x)

to_fill(x::Vector, dims...) = x
to_fill(x, dims...) = Fill(x, dims...)

default_kwargs() = (;)

default_vertex_position() = zeros(Point2)
default_vertex_position(v) = default_vertex_position()
default_vertex_position(v::Tuple{<:Number,<:Number}) = float(2Point(v))
default_vertex_position(v::Tuple{<:Number}) = default_vertex_position((float(v[1]), 0.0))
default_vertex_position(v::Number) = default_vertex_position((v,))

default_fill_color() = "white"
default_fill_color(v) = default_fill_color()

default_text() = ""
default_text(v) = default_text()
default_text_size() = "\\large"
default_text_size(v) = default_text_size()
default_text_color() = "black"
default_text_translation() = zero(Vec2)

default_shape() = zero(Point2)
default_shape(v) = default_shape()
default_shapes(v) = Fill(default_shape())
default_line_color() = "black"
default_line_color(v) = default_line_color()
default_line_style() = "solid"

default_edge_shape(e) = Line

default_line_thickness() = 2
default_edge_points(e) = []

default_corner_roundness() = 2

# Return a dictionary
to_dictionary(fmap::Function, x, indices) = to_dictionary(fmap, x, Indices(indices))
to_dictionary(fmap::Function, f::Function, indices::Indices) = map(fmap ∘ f, indices)
to_dictionary(fmap::Function, x, indices::Indices) = map(Returns(fmap(x)), indices)

to_dictionary(x, indices) = to_dictionary(identity, x, Indices(indices))

function tikz(
  g::AbstractGraph;
  vertex=default_shape(),
  vertex_position=default_vertex_position,
  vertex_kwargs=default_kwargs(),
  edge=default_edge_shape,
  edge_kwargs=default_kwargs(),
)
  vertex = to_dictionary(to_fill, vertex, vertices(g))
  vertex_position = to_dictionary(vertex_position, vertices(g))
  vertex_kwargs = to_dictionary(Base.Fix2(to_fill, ∞), vertex_kwargs, vertices(g))
  edge = to_dictionary(to_fill, edge, edges(g))
  edge_kwargs = to_dictionary(Base.Fix2(to_fill, ∞), edge_kwargs, edges(g))

  tikz_str = ""

  # Generate TikZ code for drawing edges
  for e in edges(g)
    edge_position = (vertex_position[src(e)], vertex_position[dst(e)])
    for j in reverse(eachindex(edge[e]))
      tikz_str *= tikz(
        edge_shape(edge[e][j])(edge_position...);
        get(edge_kwargs[e], j, default_kwargs())...,
      )
    end
  end

  # Generate TikZ code for drawing vertices
  for v in vertices(g)
    for j in reverse(eachindex(vertex[v]))
      tikz_str *= tikz(
        vertex_shape(vertex[v][j])(vertex_position[v]);
        get(vertex_kwargs[v], j, default_kwargs())...,
      )
    end
  end

  return tikz_str
end

tikz(; kwargs...) = tikz(Graph(1); kwargs...)

point2(s::Point1) = Point(only(s), zero(eltype(s)))
line2(s::Line{1}) = Line(point2.(coordinates(s))...)

# GeometryBasics.jl extensions
# Transformations: translation, rotation, reflection, scaling.
# https://github.com/JuliaGeometry/Rotations.jl
# https://github.com/JuliaGeometry/CoordinateTransformations.jl
# https://discourse.julialang.org/t/non-affine-transformations-in-makie/81951
# https://discourse.julialang.org/t/using-arbitrary-polygons-as-markers-in-makie-jl/53690
# https://discourse.julialang.org/t/nonorthogonal-axes-in-makie-or-maybe-in-other-plotting-package/86749
translate(s, translation) = s + translation
translate(s::Vector{<:Point2}, translation::Point2) = translate.(s, translation)
function translate(s, translation::Point1)
  return translate(s, point2(translation))
end
translate(s::Point1, translation::Point2) = translate(point2(s), translation)
function translate(s::PointMeta, translation::Point2)
  return meta(translate(metafree(s), translation); meta(s)...)
end
function translate(s::LineString, translation::Point2)
  return LineString(translate(coordinates(s), translation))
end
function translate(s::LineStringMeta, translation::Point2)
  return meta(translate(metafree(s), translation); meta(s)...)
end
function translate(s::Line, translation::Point2)
  return Line(translate(coordinates(s), translation)...)
end
function translate(s::Vec, translation::Point2)
  # TODO: Why does this become a line?
  return Line(float(translation), translate(Point(s), translation))
end
function translate(s::Circle, translation::Point2)
  return Circle(translate(s.center, translation), s.r)
end
function translate(s::Polygon, translation::Point2)
  return Polygon(translate(coordinates(s), translation))
end
function translate(s::PolygonMeta, translation::Point2)
  return meta(translate(metafree(s), translation); meta(s)...)
end

to_polygon(s::Rect) = Polygon(Point.(coordinates(s))[[1, 3, 4, 2]])

rotation_matrix(θ) = [cos(θ) -sin(θ); sin(θ) cos(θ)]
function rotate(s::Point2, θ::Float64; center=zero(Point2))
  return Point2(rotation_matrix(θ) * (s - center)) + center
end
function rotate(s::PointMeta, args...; kwargs...)
  return meta(translate(metafree(s), args...; kwargs...); meta(s)...)
end
rotate(s::Point1, args...; kwargs...) = rotate(point2(s), args...; kwargs...)
function rotate(s::Rect, args...; kwargs...)
  return rotate(to_polygon(s), args...; kwargs...)
end
function rotate(s::Polygon, args...; kwargs...)
  return Polygon(rotate.(coordinates(s), args...; kwargs...))
end
function rotate(s::PolygonMeta, args...; kwargs...)
  return meta(rotate(metafree(s), args...; kwargs...); meta(s)...)
end
function rotate(s::LineString, args...; kwargs...)
  return LineString(rotate(coordinates(s), args...; kwargs...))
end
function rotate(s::LineStringMeta, args...; kwargs...)
  return meta(rotate(metafree(s), args...; kwargs...); meta(s)...)
end
function rotate(s::Line, args...; kwargs...)
  return Line(rotate(coordinates(s), args...; kwargs...)...)
end
# TODO: How should this be defined?
# function rotate(s::Vec, args...; kwargs...)
#   return Vec(rotate(Point(s), args...; kwargs...))
# end
function rotate(s::Circle, args...; kwargs...)
  return Circle(rotate(s.center, args...; kwargs...), s.r)
end

shape(s) = s
shape(s::AbstractString) = meta(default_vertex_position(); text=s)
shape(s::LaTeXString) = meta(default_vertex_position(); text=s)

vertex_shape(s) = p -> translate(shape(s), p)

edge_shape(s) = (p1, p2) -> translate(shape(s), mean((p1, p2)))
edge_shape(s::Function) = s
edge_shape(s::Type) = s

# GeometryBasics TikZ conversion
# https://www.overleaf.com/learn/latex/TikZ_package
# https://tikz.dev/tikz-shapes
# https://tex.stackexchange.com/questions/107057/adjusting-font-size-with-tikz-picture
# \tiny
# \scriptsize
# \footnotesize
# \small
# \normalsize
# \large
# \Large
# \LARGE
# \huge
# \Huge
function tikz(
  s::Point;
  text="",
  text_size=default_text_size(),
  text_color=default_text_color(),
  kwargs...,
)
  return L"\draw %$(string(Tuple(s))) node[text=%$(text_color)] {%$(text_size) %$(text)};"
end
tikz(s::PointMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

function tikz(
  s::Line{2};
  line_thickness=default_line_thickness(),
  line_style=default_line_style(),
  line_color=default_line_color(),
  kwargs...,
)
  draw_args = "[draw=$(line_color), $(line_style), line width=$(line_thickness)pt]"
  return L"\draw%$(draw_args) %$(string(Tuple(s[1]))) -- %$(string(Tuple((s[2]))));"
end
tikz(s::Line{1}; kwargs...) = tikz(line2(s); kwargs...)
# GeometryBasics.jl doesn't have this defined right now.
# tikz(s::LineMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

tikz_shape(::Circle) = "circle"
function tikz(
  s::Circle;
  line_thickness=default_line_thickness(),
  line_style=default_line_style(),
  line_color=default_line_color(),
  fill_color=default_fill_color(),
  kwargs...,
)
  filldraw_args = "[draw=$(line_color), $(line_style), line width=$(line_thickness)pt,fill=$(fill_color)!40]"
  tikz_str = L"\filldraw%$(filldraw_args) %$(string(Tuple(s.center))) %$(tikz_shape(s)) (%$(s.r)) node {};"
  return tikz_str
end
# GeometryBasics.jl doesn't have this defined right now.
# tikz(s::CircleMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

# https://github.com/JuliaGeometry/GeometryBasics.jl/pull/73
# `decompose(Point, s)` or `coordinates(s)` returns the points composing the `LineString`.
lines(s::LineString) = decompose(Line, s)

# TODO: Consolidate with `tikz(::Polygon)`.
function tikz(
  s::LineString;
  line_thickness=default_line_thickness(),
  line_style=default_line_style(),
  line_color=default_line_color(),
  fill_color=default_fill_color(),
  corner_roundness=default_corner_roundness(),
  kwargs...,
)
  # Convert to Vector of length `length(coordinates(s))` if it is just a number
  corner_roundness = to_fill(corner_roundness, length(coordinates(s)))
  draw_args = "[draw=$(line_color), $(line_style), line width=$(line_thickness)pt]"
  tikz_str = "\\draw$(draw_args) $(string(Tuple(coordinates(s)[1]))) "
  for i in 2:(length(coordinates(s)) - 1)
    tikz_str *= "{[rounded corners=$(corner_roundness[i - 1])pt] -- $(string(Tuple(coordinates(s)[i])))} "
  end
  tikz_str *= " -- $(string(Tuple(coordinates(s)[end])));"
  return tikz_str
end
tikz(s::LineStringMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

# Always makes a closed shape, use `LineString` to make connected lines.
# TODO: Consolidate with `tikz(::LineString)`.
function tikz(
  s::Polygon;
  line_thickness=default_line_thickness(),
  line_style=default_line_style(),
  line_color=default_line_color(),
  fill_color=default_fill_color(),
  corner_roundness=default_corner_roundness(),
  kwargs...,
)
  # Convert to Vector of length `length(coordinates(s))` if it is just a number
  corner_roundness = to_fill(corner_roundness, length(coordinates(s)))
  filldraw_args = "[draw=$(line_color),$(line_style), line width=$(line_thickness)pt,fill=$(fill_color)!40]"
  tikz_str = "\\filldraw$(filldraw_args) $(string(Tuple(coordinates(s)[1]))) "
  for i in 2:length(coordinates(s))
    tikz_str *= "{[rounded corners=$(corner_roundness[i])pt] -- $(string(Tuple(coordinates(s)[i])))} "
  end
  tikz_str *= "{[rounded corners=$(corner_roundness[1])pt] -- cycle};"
  return tikz_str
end
tikz(s::PolygonMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

function tikz(s::Rect; kwargs...)
  return tikz(to_polygon(s); kwargs...)
end
# GeometryBasics.jl doesn't have this defined right now.
# tikz(s::RectMeta; kwargs...) = tikz(metafree(s); kwargs..., meta(s)...)

end
