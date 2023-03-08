module GraphTikZ
  using GeometryBasics
  using Graphs
  using LaTeXStrings

  export DanglingEdge, tikz

  # Defaults
  default_vertex_shape(v, position) = Circle(position, 0.5)
  default_vertex_label(v, position) = (; text=string(v), position)
  default_fill_color(v=nothing) = "white"
  default_line_thickness() = "ultra thick"

  """
  Represents a vertex at the end of a dangling edge of the graph.
  """
  struct DanglingEdge{T,V}
    vertex::V
  end
  DanglingEdge{T}(vertex) where {T} = DanglingEdge{T,typeof(vertex)}(vertex)
  DanglingEdge(vertex) = DanglingEdge{1}(vertex)

  default_vertex_shape(v::DanglingEdge, position) = position
  default_vertex_label(v::DanglingEdge, position) = (; text="", position)

  function tikz(g::AbstractGraph;
    vertex_position,
    vertex_shape=default_vertex_shape,
    vertex_label=default_vertex_label,
    vertex_fill_color=default_fill_color,
  )
    tikz_str = ""
    for e in edges(g)
      tikz_str *= tikz(Line(vertex_position(src(e)), vertex_position(dst(e))))
    end
    for v in vertices(g)
      tikz_str *= tikz(vertex_shape(v, vertex_position(v)); fill_color=vertex_fill_color(v))
      (; text, position) = vertex_label(v, vertex_position(v))
      tikz_str *= tikz(position; text)
    end
    return tikz_str
  end

  # GeometryBasics TikZ conversion
  # https://www.overleaf.com/learn/latex/TikZ_package
  # https://tikz.dev/tikz-shapes
  function tikz(s::Point; text="", fill_color=nothing)
    return L"\draw %$(string(Tuple(s))) node {%$(text)};"
  end

  function tikz(
    s::Line{2};
    line_thickness=default_line_thickness(),
  )
    return L"\draw[%$(line_thickness)] %$(string(Tuple(s[1]))) -- %$(string(Tuple((s[2]))));"
  end

  tikz_shape(::Circle) = "circle"
  function tikz(
    s::Circle;
    line_thickness=default_line_thickness(),
    line_color="black",
    fill_color=default_fill_color(),
  )
    filldraw_args = "draw=$(line_color),$(line_thickness),fill=$(fill_color)!40"
    tikz_str = L"\filldraw[%$(filldraw_args)] %$(string(Tuple(s.center))) %$(tikz_shape(s)) (%$(s.r)) node {};"
    return tikz_str
  end

  tikz_shape(::Rect2) = "rectangle"
  function tikz(
    s::Rect;
    line_thickness=default_line_thickness(),
    line_color="black",
    fill_color=default_fill_color(),
  )
    filldraw_args = "draw=$(line_color),rounded corners,$(line_thickness),fill=$(fill_color)!40"
    tikz_str = L"\filldraw[%$(filldraw_args)] %$(string(Tuple(s.origin))) %$(tikz_shape(s)) %$(string(Tuple(s.widths))) node {};"
    return tikz_str
  end

  function tikz(
    s::Polygon;
    line_thickness=default_line_thickness(),
    line_color="black",
    fill_color=default_fill_color(),
  )
    filldraw_args = "draw=$(line_color),rounded corners,$(line_thickness),fill=$(fill_color)!40"
    tikz_str = "\\filldraw[$(filldraw_args)] "
    for p in coordinates(s)
      tikz_str *= "$(string(Tuple(p))) -- "
    end
    tikz_str *= "cycle;"
    return tikz_str
  end
end
