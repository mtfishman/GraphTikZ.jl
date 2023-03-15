module GraphTikZ
  using DataGraphs
  using GeometryBasics
  using Graphs
  using LaTeXStrings

  export tikz

  default_position(v) = zeros(Point2)
  default_position(v::Tuple{<:Number,<:Number}) = float(2Point(v))
  default_position(v::Tuple{<:Number}) = default_position((float(v[1]), 0.0))
  default_position(v::Number) = default_position((v,))

  default_shape() = zero(Point2)
  default_fill_color() = "white"
  default_fill_color(v) = default_fill_color()

  default_text() = ""
  default_text(v) = default_text()
  default_text_size() = "\\large"
  default_text_size(v) = default_text_size()
  default_text_translation() = zero(Vec2)

  default_shape(v) = zero(Point2)
  default_line_color() = "black"

  default_line_thickness() = "ultra thick"
  default_edge_points(e) = []

  ## tikz(; kwargs...) = tikz(Graph(1); kwargs...)

  function tikz(g::DataGraph)
    tikz_str = ""
    for e in edges(g)
      e_data = get(g, e, Dict())
      edge_points = get(e_data, :edge_points, default_edge_points(e))
      src_data = get(g, src(e), Dict())
      dst_data = get(g, dst(e), Dict())
      src_position = get(src_data, :position, default_position(src(e)))
      dst_position = get(dst_data, :position, default_position(dst(e)))

      # TODO: Allow customization.
      # TODO: Use `Statistics.mean`.
      position = (src_position + dst_position) / 2

      tikz_str *= tikz(LineString(Point2{Float64}[[src_position]; edge_points; [dst_position]]))
      edge_shape = get(e_data, :edge_shape, default_shape())
      edge_shapes = edge_shape isa Vector ? edge_shape : [edge_shape]
      edge_fill_color = get(e_data, :edge_fill_color, default_fill_color())
      edge_fill_colors = edge_fill_color isa Vector ? edge_fill_color : fill(edge_fill_color, length(edge_shapes))
      edge_text = get(e_data, :edge_text, default_text())
      edge_text_size = get(e_data, :edge_text_size, default_text_size())
      edge_text_translation = get(e_data, :edge_text_translation, default_text_translation())
      # Edge shape
      for j in eachindex(edge_shapes)
        edge_shape = get(edge_shapes, j, default_shape())
        edge_fill_color = get(edge_fill_colors, j, default_fill_color())
        tikz_str *= tikz(translate(edge_shape, position); fill_color=edge_fill_color)
      end
      # Edge text
      tikz_str *= tikz(position + edge_text_translation; text=edge_text, text_size=edge_text_size)
    end
    for v in vertices(g)
      data = get(g, v, Dict())
      position = get(data, :position, default_position(v))
      shape = get(data, :shape, default_shape())
      shapes = shape isa Vector ? shape : [shape]
      fill_color = get(data, :fill_color, default_fill_color())
      fill_colors = fill_color isa Vector ? fill_color : fill(fill_color, length(shapes))
      text = get(data, :text, default_text())
      text_size = get(data, :text_size, default_text_size())
      text_translation = get(data, :text_translation, default_text_translation())
      # Vertex shape
      for j in eachindex(shapes)
        shape = get(shapes, j, default_shape())
        fill_color = get(fill_colors, j, default_fill_color())
        tikz_str *= tikz(translate(shape, position); fill_color)
      end
      # Vertex text
      tikz_str *= tikz(position + text_translation; text, text_size)
    end
    return tikz_str
  end

  to_function(f::Function) = f
  to_function(x) = Returns(x)

  function tikz(
    g::AbstractGraph;
    position=default_position,
    text=default_text,
    text_size=default_text_size,
    shape=default_shape,
    fill_color=default_fill_color,
    edge_text=default_text,
    edge_text_size=default_text_size,
    edge_shape=default_shape,
    edge_fill_color=default_fill_color,
    edge_points=default_edge_points,
  )
    kwargs = (; position, text, text_size, shape, fill_color, edge_text, edge_text_size, edge_shape, edge_fill_color, edge_points)
    kwargs = map(to_function, kwargs)
    (; position, text, text_size, shape, fill_color, edge_text, edge_text_size, edge_shape, edge_fill_color, edge_points) = kwargs
    dg = DataGraph(g)
    for v in vertices(dg)
      v_data = Dict()
      v_data[:position] = position(v)
      v_data[:shape] = shape(v)
      v_data[:text] = text(v)
      v_data[:text_size] = text_size(v)
      v_data[:fill_color] = fill_color(v)
      dg[v] = v_data
    end
    for e in edges(dg)
      e_data = Dict()
      ## e_data[:position] = edge_position(v)
      e_data[:edge_shape] = edge_shape(e)
      e_data[:edge_text] = edge_text(e)
      e_data[:edge_text_size] = edge_text_size(e)
      e_data[:edge_fill_color] = edge_fill_color(e)
      e_data[:edge_points] = edge_points(e)
      dg[e] = e_data
    end
    return tikz(dg)
  end

  tikz(; kwargs...) = tikz(Graph(1); kwargs...)

  function tikz(
    shapes::Vector;
    kwargs...,
  )
    return tikz(; shape=shapes, kwargs...)
  end

  # GeometryBasics.jl extensions
  # Transformations: translation, rotation, reflection, scaling.
  # https://github.com/JuliaGeometry/Rotations.jl
  # https://github.com/JuliaGeometry/CoordinateTransformations.jl
  # https://discourse.julialang.org/t/non-affine-transformations-in-makie/81951
  # https://discourse.julialang.org/t/using-arbitrary-polygons-as-markers-in-makie-jl/53690
  # https://discourse.julialang.org/t/nonorthogonal-axes-in-makie-or-maybe-in-other-plotting-package/86749
  translate(s, translation) = s + translation
  function translate(s::LineString, translation)
    return LineString(coordinates(s) .+ translation)
  end
  function translate(s::Line, translation)
    return Line((coordinates(s) .+ translation)...)
  end
  function translate(s::Vec, translation)
    return Line(translation, Point(s) + translation)
  end
  function translate(s::Circle, translation)
    return Circle(s.center + translation, s.r)
  end

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
  function tikz(s::Point; text="", fill_color=default_fill_color(), text_size=default_text_size())
    return L"\draw %$(string(Tuple(s))) node {%$(text_size) %$(text)};"
  end

  function tikz(
    s::Line{2};
    line_thickness=default_line_thickness(),
    line_color=default_line_color(),
    fill_color=default_fill_color(),
  )
    draw_args = "[draw=$(line_color),$(line_thickness)]"
    return L"\draw%$(draw_args) %$(string(Tuple(s[1]))) -- %$(string(Tuple((s[2]))));"
  end

  tikz_shape(::Circle) = "circle"
  function tikz(
    s::Circle;
    line_thickness=default_line_thickness(),
    line_color=default_line_color(),
    fill_color=default_fill_color(),
  )
    filldraw_args = "[draw=$(line_color),$(line_thickness),fill=$(fill_color)!40]"
    tikz_str = L"\filldraw%$(filldraw_args) %$(string(Tuple(s.center))) %$(tikz_shape(s)) (%$(s.r)) node {};"
    return tikz_str
  end

  tikz_shape(::Rect2) = "rectangle"
  function tikz(
    s::Rect;
    line_thickness=default_line_thickness(),
    line_color=default_line_color(),
    fill_color=default_fill_color(),
  )
    filldraw_args = "[draw=$(line_color),rounded corners,$(line_thickness),fill=$(fill_color)!40]"
    tikz_str = L"\filldraw%$(filldraw_args) %$(string(Tuple(s.origin))) %$(tikz_shape(s)) %$(string(Tuple(s.origin + s.widths))) node {};"
    return tikz_str
  end

  # https://github.com/JuliaGeometry/GeometryBasics.jl/pull/73
  # `decompose(Point, s)` or `coordinates(s)` returns the points composing the `LineString`.
  lines(s::LineString) = decompose(Line, s)
  function tikz(
    s::LineString;
    line_thickness=default_line_thickness(),
    line_color=default_line_color(),
    fill_color=default_fill_color(),
    rounded_corners=true,
  )
    filldraw_args = "[draw=$(line_color),rounded corners,$(line_thickness)]"
    tikz_str = "\\draw$(filldraw_args) "
    for p in coordinates(s)
      tikz_str *= "$(string(Tuple(p))) -- "
    end
    tikz_str = chop(tikz_str; tail=4)
    tikz_str *= ";"
    return tikz_str
  end

  # Always makes a closed shape, use `LineString` to make connected lines.
  function tikz(
    s::Polygon;
    line_thickness=default_line_thickness(),
    line_color=default_line_color(),
    fill_color=default_fill_color(),
  )
    filldraw_args = "[draw=$(line_color),rounded corners,$(line_thickness),fill=$(fill_color)!40]"
    tikz_str = "\\filldraw$(filldraw_args) "
    for p in coordinates(s)
      tikz_str *= "$(string(Tuple(p))) -- "
    end
    tikz_str *= "cycle;"
    return tikz_str
  end
end
