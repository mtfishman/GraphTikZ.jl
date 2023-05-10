using GeometryBasics
using Graphs
using LaTeXStrings
using NamedGraphs
using TikzPictures
using GraphTikZ
using GraphTikZ: rotate

using Random
using DataGraphs
using GeometryBasics
using Graphs
using GraphTikZ
using LaTeXStrings
using LinearAlgebra 
using NamedGraphs
using NetworkLayout
using TikzPictures

using Dictionaries

using NamedGraphs: rem_edges!, steiner_tree, random_bfs_tree, add_edges!, rem_vertex!

save_root = "/Users/jtindall/Documents/Figures/BPandVidalGauge/TikZ/"

t_rad = 0.5
b_rad = 0.4
t_label_size  = "\\normalsize"
mt_label_size = "\\tiny"
bt_label_size = "\\tiny"

polygon_dist = 0.5
lvec, rvec, uvec, dvec = Vec(-1.0, 0.0), Vec(1.0, 0.0), Vec(0.0, 1.0), Vec(0.0, -1.0)
circ = Circle(Point(0.0, 0.0), t_rad)
s_circ = Circle(Point(0.0, 0.0), b_rad)
vert_dist = 1.4

polygon_dist = 0.45
p = Polygon([Point2(-polygon_dist, -polygon_dist), Point2(polygon_dist, -polygon_dist), Point2(polygon_dist, polygon_dist), Point2(-polygon_dist, polygon_dist)])
left_triangle = meta(p; corner_roundness = [2, 2, 14, 14])
right_triangle = meta(p; corner_roundness = [14, 14, 2, 2])

square = Polygon([Point2(-0.5, -0.5), Point2(-0.5, 0.5), Point2(0.5, 0.5), Point2(0.5, -0.5)])

#Some general Tensor Network states: MPS, PEPS, Tree, General TN
function example_TNSs()
    cur_position = zeros(Point2)

    #MPS
    graph = named_grid((5,1))
    tikz_str = tikz(graph; vertex_position= vertex_position=v->1.5*Point(v) + Point(7, 4),vertex = v-> [L"T_{%$(v[1])}", circ, dvec],vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(; vertex_position= Point(7.5, 6),vertex = v-> [L"\textbf{a)}"])
    tikz_str *= tikz(; vertex_position= Point(5.3, 4.0),vertex = v-> [L"\textbf{b)}"])
    tikz_str *= tikz(; vertex_position= Point(12.3, 3.5),vertex = v-> [L"\textbf{c)}"])
    tikz_str *= tikz(; vertex_position= Point(6, -1.25),vertex = v-> [L"\textbf{d)}"])

    cur_position = cur_position + Point(3.0, 5)

    #PEPS
    graph = named_grid((3,3))
    tikz_str *= tikz(graph;vertex_position=v->cur_position + Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)), vertex = v-> [L"T_{%$(v[1]),%$(v[2])}", circ, dvec],vertex_kwargs = (; fill_color = "blue"))

    cur_position = cur_position + Point(13, -3)

    #Tree
    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))
    t_graph = random_bfs_tree(graph, 1)
    positions = spring(t_graph)
    tikz_str *= tikz(t_graph;vertex_position=v-> cur_position + 0.75*positions[v], vertex = v-> [L"T_{%$(v)}", circ, dvec],vertex_kwargs = (; fill_color = "blue"))

    cur_position = Point(4, -4)

    #General Network
    positions = spring(graph)
    positions[4] += Point2(1, -0.75)
    rem_edges!(graph, [3=>5])
    tikz_str *= tikz(graph;vertex_position=v-> cur_position + Point(3, 0) +  1.5positions[v], vertex = v-> [L"T_{%$(v)}", circ, dvec],vertex_kwargs = (; fill_color = "blue"))

    cur_position = cur_position + Point(10, 0)



    tikz_str *= tikz(; vertex_position= Point(13.0, -1.25),vertex = v-> [L"\textbf{e)}"])

    tikz_str *= tikz(graph;
    vertex_position=v-> cur_position + 1.5positions[v], vertex = v-> (v == 1 || v == 5) ? [L"\Gamma_{%$(v[1])}", circ, 0.7*dvec] : [L"\Gamma_{%$(v[1])}", circ, dvec],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[L"\Lambda_{%$(src(e)),%$(dst(e))}",s_circ, Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")])

    save(PDF(save_root*"example_TNSs"), TikzPicture(tikz_str))

end

#Isometry Condition
function isometry_condition()

    cur_position = zeros(Point2)
    graph = named_grid((1,2))
    v1, v2 = vertices(graph)[1], vertices(graph)[2]

    shift = 0.5
    lines1 = [
        LineString([Point(0.0, 0.0), Point(-2.0, shift), Point(-2.0, 2.0 + shift), Point(0.0, 2.0)]),
        ]
    
    lines2 = [
    LineString([Point(0.0, 0.0), Point(-2.3, -shift), Point(-2.3, -2 - shift), Point(0.0, -2.0)]),
    ]
    tikz_str = tikz(;
    vertex_position=cur_position + 2(Point(v1) - Point(0.0, 2.0)), vertex = [lines1;], vertex_kwargs = (; fill_color = "black"))
    tikz_str *= tikz(;
    vertex_position=cur_position + 2(Point(v2) - Point(0.0, 2.0)), vertex = [lines2;], vertex_kwargs = (; fill_color = "black"))


    cur_position = zeros(Point2)

    tikz_str *= tikz(
    graph; vertex_position=v -> cur_position + 2(Point(v) - Point(0.0, 2.0)), 
    vertex = v-> iseven(v[2]) ? [L"\Gamma_{v}", circ, sqrt(2)*rvec] : [L"\Gamma^{*}_{v}", circ, sqrt(2)*rvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= "\\draw [dotted, line width = 1pt] (2.75, 0.0) arc [start angle = 0, end angle = 150, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= "\\draw [dotted, line width = 1pt] (2.75, -2) arc [start angle = 0, end angle = -150, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(4.0, -1.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(5.0, -1.0),
    vertex=[[
        LineString([Point(1.0, -1.0), Point(0.0, -1.0), Point(0.0, 0.0), Point(0.0, 1.0), Point(1.0, 1.0)]),
        ];],
    )

    save(PDF(save_root*"IsometryCondition"), TikzPicture(tikz_str))
end

#Norm Tensor Definition
function norm_tensor()
    cur_position = zeros(Point2)
    g = named_grid((1,2))
    #Part 1
    tikz_str = tikz(g
        ; vertex_position = v-> cur_position + 1.2*Point(v), vertex =  v-> iseven(v[2]) ? [L"T_{v}", circ, lvec, rvec, (1/sqrt(2))*Vec(-1.0, 1.0), (1/sqrt(2))*Vec(1.0, -1.0)] : [L"T^{*}_{v}", circ, lvec, rvec, (1/sqrt(2))*Vec(-1.0, 1.0), (1/sqrt(2))*Vec(1.0, -1.0)] ,
        vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= "\\draw [dotted, line width = 1pt] (2.0, 2.4) arc [start angle = 0, end angle = 125, x radius = 0.75cm, y radius = 0.75cm];"

    tikz_str *= "\\draw [dotted, line width = 1pt] (1.7, 0.7) arc [start angle = -45, end angle = -180, x radius = 0.75cm, y radius = 0.75cm];"

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(3.0, 1.75), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point(3.5, 0.8)

    tikz_str *= "\\draw [dotted, line width = 1pt] (5.3, 1.8) arc [start angle = 0, end angle = 125, x radius = 0.75cm, y radius = 0.75cm];"

    tikz_str *= "\\draw [dotted, line width = 1pt] (5.0, 1.2) arc [start angle = -45, end angle = -180, x radius = 0.75cm, y radius = 0.75cm];"

    g = named_grid((1,1))
    tikz_str *= tikz(g
        ; vertex_position = v-> cur_position + Point(v), vertex =  v-> [L"\mathcal{T}_{v}", circ, lvec, rvec, (1/sqrt(2))*Vec(-1.0, 1.0), (1/sqrt(2))*Vec(1.0, -1.0)],
        vertex_kwargs = (; fill_color = "blue", line_thickness = 3.2))

    save(PDF(save_root*"NormTensor"), TikzPicture(tikz_str))
    
end

#Belief Propagation
function belief_propagation_diagrams()
    
    cur_position = zeros(Point2)
    #Part 1
    tikz_str = tikz(
    ; vertex_position = cur_position, vertex = v-> [L"\mathcal{T}_{v}", circ, 1.75*rvec, sqrt(2)*lvec, lvec + uvec, rvec + Point2(0.0, 0.75), rvec + Point2(0.0, -0.75)],
    vertex_kwargs = (; fill_color = "blue", line_thickness = 3.2))

    tikz_str *= tikz(; vertex_position = cur_position + Point(-1.5, 0.0), vertex = [L"M_{v_{N}, v}", circ],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(;  vertex_position = cur_position + Point(-1.3, 1.3), vertex = [L"M_{v_{1}, v}", circ],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(; vertex_position = cur_position + sqrt(2)*Point(1.0, 0.75),
    vertex = [L"M_{v_{i-1}, v}", circ], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(; vertex_position = cur_position + sqrt(2)*Point(1.0, -0.75),
    vertex = [L"M_{v_{i+1}, v}", circ], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    points = generate_arc(Point2(-1, 0.5), Point2(0.3, -0.4), 0.8; theta_shift = 2.5, npoints = 5)
    lines = [
      LineString(points),
    ]

    tikz_str *= "\\draw [dotted, line width = 1pt] (0.6, -0.6) arc [start angle = -45, end angle = -170, x radius = 0.825cm, y radius = 0.825cm];"


    tikz_str *= "\\draw [dotted, line width = 1pt] (0.6, 0.6) arc [start angle = 45, end angle = 130, x radius = 0.9cm, y radius = 0.9cm];"

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(2.25, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position = cur_position + Point(3.5, 0.0), vertex = [L"M_{v, v_{i}}", circ, 1.75*rvec],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size, line_thickness = 3.2))

    save(PDF(save_root*"MessageTensorUpdate"), TikzPicture(tikz_str))

    #Part 2
    cur_position = zeros(Point2)
    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))
    vertex_central = vertices(graph)[6]
    subgraph_vertices = vcat(findall(v -> v ∈ neighbors(graph, vertex_central), vertices(graph)), [vertex_central])

    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))

    positions = spring(graph)
    tikz_str = tikz(
    graph; vertex_position=v-> cur_position + 1.5positions[v], 
    vertex = v->  v != vertex_central ? [L"\mathcal{T}_{%$(v[1])}", circ] : ["", circ],
    vertex_kwargs = v-> v!= vertex_central ? (; fill_color = "blue") : (; fill_color = "white", line_color = "white"),
    edge_kwargs = e -> (; line_thickness = 3.2))

    #Need kwarg, edge_line_color here
    positions = spring(graph)
    tikz_str *= tikz(
    graph[subgraph_vertices];
    vertex_position=v-> cur_position + + Point(5.75, 0) + 1.0positions[v],
    vertex = v -> v ∈ neighbors(graph, vertex_central) ? [L"M_{%$(v[1]), 6}", circ] : ["", circ],
    vertex_kwargs = v-> v ∈ neighbors(graph, vertex_central) ? (; fill_color = "black", text_size = mt_label_size) :
        (; fill_color = "white", text_size = mt_label_size, line_color = "white"),
    edge_kwargs= e -> src(e) ∈ neighbors(graph, vertex_central) || dst(e) ∈ neighbors(graph, vertex_central) ? [(; fill_color="black", line_thickness = 3.2)] : [(; fill_color="none", line_thickness = 3.2, shape_line_thickness = 0.0)])

    tikz_str *= tikz(; vertex=[L"\approx"], vertex_position=cur_position + Point(3.25, 0.5), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\lambda_{6}"], vertex_position=cur_position + Point(4.0, 0.5), vertex_kwargs = (; text_size = "\\Large"))



    save(PDF(save_root*"MessageTensorEnvironment"), TikzPicture(tikz_str))

end

#MPS Belief Propagation Step
function belief_propagation_MPS()

    graph = named_grid((2,1))
    cur_position = Point(-2.0, 0.0)

    tikz_str = tikz(graph; vertex_position= v-> cur_position + 1.4*(Point(v) - Point(1.0, 1.0)),
    vertex = v -> isodd(v[1]) ? [L"M_{v - 1, v}", circ] : [L"\mathcal{T}_{v}", circ, rvec],
    vertex_kwargs = v -> isodd(v[1]) ? (; fill_color = "black", text_size = mt_label_size, line_thickness = 3.2) : (; fill_color = "blue", line_thickness = 3.2),
    edge_kwargs = e -> (; line_thickness = 3.2))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(3.0, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position = cur_position + Point(3.5, 0.0)

    graph = named_grid((1,2))

    lines = [
        LineString([Point(-0.475, 0.0), Point(-1.0, 0.0), Point(-1.0, -1.4), Point(-0.475, -1.4)]),
        ]

    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.5)),
    vertex = v-> isodd(v[2]) ? [L"T^{*}_{v}", circ, rvec] : [[L"T_{v}", circ, rvec]; lines],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(; vertex_position = Point(1.9, 0.0), vertex = [L"M_{v - 1, v}", circ], vertex_kwargs = (; text_size = mt_label_size, fill_color = "black"))
    
    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(3.25, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position = cur_position + Point(3.25, 0.0)
    graph = named_grid((1,1))

    lines = [
        LineString([Point(0.0, 0.0), Point(0.0,0.7), Point(1.0, 0.7)]),
        LineString([Point(0.0, 0.0), Point(0.0, -0.7), Point(1.0, -0.7)])
        ]

    tikz_str *= tikz(graph; vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex= v-> [[L"M_{v, v + 1}", circ]; lines], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(3.75, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position = cur_position + Point(3.75, 0.0)

    graph = named_grid((1,1))

    tikz_str *= tikz(graph; vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = [L"M_{v, v + 1}", circ, rvec], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size, line_thickness = 3.2))

    save(PDF(save_root*"MessageTensorUpdateMPS"), TikzPicture(tikz_str))

end

#Belief Propagation Identity
function MPSBeliefPropagationidentity()
    cur_position = zeros(Point2)

    graph = named_grid((2,2))
    rem_edges!(graph, [(2,1) => (2,2)])

    lines1 = [
      LineString([Point(-0.4, 0.0), Point(-1.0, 0.0), Point(-1.0, 0.7)]),
    ]
    lines2 = [
      LineString([Point(-0.4, 0.0), Point(-1.0, 0.0), Point(-1.0, -0.7)]),
    ]

    keys = [
      (1, 1),
      (1, 2),
      (2, 1),
      (2, 2),
    ]
    vals = [
      [[L"T^{*}_{v}", circ]; lines1],
      [[L"T_{v}", circ]; lines2],
      [L"M^{-\frac{1}{2}}_{v,v+1}", circ, rvec],
      [L"M^{-\frac{1}{2}}_{v,v+1}", circ, rvec],
    ]
    vertex_dict = Dictionary(keys, vals)

    tikz_str = ""

    # Right hand side
    tikz_str = tikz(;
    vertex_position=cur_position + Point(5.0, 0.0),
    vertex=[[
        LineString([Point(1.0, -vert_dist/2), Point(0.0, -vert_dist/2), Point(0.0, 0.0), Point(0.0, vert_dist
        /2), Point(1.0, vert_dist/2)]),
        ];],
    )

    # Equals sign
    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(4.0, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    # Left hand side

    # Transfer matrix
    tikz_str *= tikz(graph;
    vertex_position= v-> cur_position + vert_dist*(Point(v) - Point(0.0, 1.5)),
    vertex = v-> vertex_dict[v],
    vertex_kwargs = v-> v[1] == 1 ? (; fill_color = "blue") : (; text_size = mt_label_size, fill_color = "black"))

    # Left message tensor
    tikz_str *= tikz(; vertex_position = cur_position + Point(0.4, 0.0), vertex = [L"M_{v-1,v}", circ], vertex_kwargs = (; text_size = mt_label_size, fill_color = "black"))

    save(PDF(save_root*"BeliefPropagationIdentityMPS"), TikzPicture(tikz_str))
end

#Define the SVD of $M_{i, i+1}^{.5}M_{i+1, i}^{.5}%
function SVD_RootM_MPS()
    graph = named_grid((2,1))
    cur_position = Point2(0.0, 0.0)

    tikz_str = tikz(graph; 
    vertex_position= v-> cur_position + 1.4Point2(v) - 1.4Point2(0.0, 1.0),
    vertex = v-> isodd(v[1]) ? [L"M^{\frac{1}{2}}_{v, v + 1}", circ,lvec] : [L"M^{\frac{1}{2}}_{v + 1, v}", circ, rvec],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size)
    )

    tikz_str *= tikz(; vertex_position=cur_position + Point(5.0, 0.0), vertex = [L"\approx"], vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"{\rm SVD}"], vertex_position=cur_position + Point(5.0, 0.5), vertex_kwargs = (; text_size = "\\normalsize"))

    graph = named_grid((3,1))
    cur_position = cur_position + Point(6.0, 0.0)


    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v-> v[1] == 1 ? [L"U_{v, v + 1}", right_triangle, lvec] : v[1] == 3 ? [L"V_{v + 1, v}", left_triangle,  rvec] : [L"\Lambda_{v, v + 1}", s_circ],
    vertex_kwargs = v -> v[1] == 2 ? (; fill_color = "black", text_size = bt_label_size) : (; fill_color = "orange", text_size = mt_label_size))

    save(PDF(save_root*"SVD_RootMessageTensorsMPS"), TikzPicture(tikz_str))

end

#Isometries of the UV tensors
function UV_isometries()
    graph = named_grid((2,1))
    cur_position = zeros(Point2)


    tikz_str = tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v-> v[1] == 1 ? [L"U_{v, v + 1}", left_triangle, lvec] : [L"U^{*}_{v, v + 1}", right_triangle,  rvec],
    vertex_kwargs = (; fill_color = "orange", text_size = mt_label_size))

    cur_position += Point(5.0, 0.0)

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position, vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex_position = cur_position, vertex = [[LineString([Point(1.0, 0.0), Point(2.0, 0.0)])] ;])

    save(PDF(save_root*"UIsometry"), TikzPicture(tikz_str))

    cur_position  = zeros(Point2)

    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v-> v[1] == 1 ? [L"V_{v + 1, v}", left_triangle, lvec] : [L"V^{*}_{v + 1, v}", right_triangle,  rvec],
    vertex_kwargs = (; fill_color = "orange", text_size = mt_label_size))

    cur_position += Point(5.0, 0.0)

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position, vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex_position = cur_position, vertex = [[LineString([Point(1.0, 0.0), Point(2.0, 0.0)])] ;])

    save(PDF(save_root*"VIsometry"), TikzPicture(tikz_str))
end

#Define \Gamma_{v} for an MPS
function Gamma_MPS()
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position,
    vertex = [L"\Gamma_{v}", circ, lvec, rvec, dvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(2.0, 0.0), vertex_kwargs = (; text_size="\\Large"))

    graph = named_grid((5,1))
    cur_position = cur_position + Point(2.75, 0.0)

    vert_dict = Dict([((1,1),[L"V_{v, v - 1}", left_triangle, lvec]), ((2,1),[ L"M^{-\frac{1}{2}}_{v, v - 1}", circ]), ((3,1),[L"T_{v}", circ, dvec]),
        ((4,1),[L"M^{-\frac{1}{2}}_{v, v + 1}", circ]), ((5,1),[L"U_{v, v + 1}", right_triangle, rvec])])
    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> vert_dict[v],
    vertex_kwargs = v -> v[1] == 3 ? (; fill_color = "blue") : v[1] == 1 || v[1] == 5 ? (; fill_color = "orange", text_size = mt_label_size) : (; fill_color = "black", text_size = mt_label_size))

    save(PDF(save_root*"GammaMPS"), TikzPicture(tikz_str))

end

#Define \Lambda_{v} for an MPS
function Lambda_MPS()
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position,
    vertex = [L"\Lambda_{v, v + 1}", s_circ, lvec, rvec],
    vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(2.5, 0.0), vertex_kwargs = (;text_size = "\\Large"))

    graph = named_grid((4,1))
    cur_position = cur_position + Point(4.0, 0.0)

    vert_dict = Dict([((1,1), [L"U_{v, v + 1}", left_triangle,  lvec]), ((2,1), [L"M^{\frac{1}{2}}_{v, v + 1}", circ]), ((3,1), [L"M^{\frac{1}{2}}_{v + 1, v}", circ]), ((4,1), [L"V_{v, v + 1}", right_triangle, rvec])])
    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> vert_dict[v],
    vertex_kwargs = v->v[1] == 1 || v[1] == 4 ? (; fill_color = "orange", text_size = mt_label_size) : (; fill_color = "black", text_size = mt_label_size))

    save(PDF(save_root*"LambdaMPS"), TikzPicture(tikz_str))

end

#Define Gauged MPS
function vidal_gauge_MPS()

    graph = named_grid((3,1))
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(graph; 
    vertex_position= v-> cur_position + 1.3*(Point(v) - Point(0.0, 1.0)),
    vertex = v->[L"T_{%$(v[1])}", Circle(Point(0.0, 0.0), 0.4), dvec, 0.8*rvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(; vertex=[L"\ldots"], vertex_position=cur_position + Point(5.1, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point(6.25, 0.0)

    tikz_str *= tikz(; vertex_position = cur_position, vertex = [L"T_{N}", Circle(Point(0.0, 0.0), 0.4), 0.8*lvec, dvec], vertex_kwargs = (;fill_color = "blue"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(1.0, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 2.0*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> v[1] != 3 ? [L"\Gamma_{%$(v[1])}",Circle(Point(0.0, 0.0), 0.4), dvec] : [L"\Gamma_{%$(v[1])}", Circle(Point(0.0, 0.0), 0.4), dvec, 0.8*rvec],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->
    [L"\Lambda_{%$(src(e)[1]),%$(dst(e)[1])}",Circle(Point(0.0, 0.0), 0.3), Line],
    edge_kwargs=[(; text_size="\\small"), (; fill_color="black")])

    tikz_str *= tikz(; vertex=[L"\ldots"], vertex_position=cur_position + Point(7.25, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point(8.5, 0.0)

    tikz_str *= tikz(; vertex_position = cur_position, vertex = [ L"\Gamma_{N}", Circle(Point(0.0, 0.0), 0.4), 0.8*lvec, dvec], vertex_kwargs = (;fill_color = "blue"))

    save(PDF(save_root*"VidalGaugeMPS"), TikzPicture(tikz_str))


end

#Left right Vidal condition for an MPS
function vidal_gauge_isometries_MPS()

    cur_position = zeros(Point2)
    graph = named_grid((1,2))
    v1, v2 = vertices(graph)[1], vertices(graph)[2]
    lines1 = [
        LineString([Point(0.0, 0.0), Point(-2, 0.0), Point(-2, vert_dist), Point(0.0, vert_dist)]),
        ]
    
    tikz_str = tikz(;
    vertex_position=cur_position + vert_dist*(Point(v1) - Point(0.0, 2.0)), vertex = [lines1;], vertex_kwargs = (; fill_color = "black"))

    tikz_str *= tikz(graph; vertex_position=v -> cur_position + vert_dist*(Point(v) - Point(0.0, 2.0)),
    vertex = v -> iseven(v[2]) ? [L"\Gamma_{v}", circ, sqrt(2)*rvec] : [L"\Gamma^{*}_{v}", circ, sqrt(2)*rvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(0, 0), vertex = [L"\Lambda_{v - 1, v}", Circle(Point(0.0, 0.0), 0.425)],
    vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(0.0, -vert_dist), vertex = [L"\Lambda_{v - 1, v}", Circle(Point(0.0, 0.0), 0.425)],
    vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(3.5, -vert_dist/2), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(4.5, -vert_dist/2),
    vertex=[[
        LineString([Point(1.0, -vert_dist/2), Point(0.0, -vert_dist/2), Point(0.0, 0.0), Point(0.0, vert_dist/2), Point(1.0, vert_dist/2)]),
        ];],
    )

    save(PDF(save_root*"LeftVidalIsometryMPS"), TikzPicture(tikz_str))
    cur_position += zeros(Point2)

    lines1 = [
        LineString([Point(0.0, 0.0), Point(2.0, 0.0), Point(2.0, vert_dist), Point(0.0, vert_dist)]),
        ]
    
    tikz_str = tikz(;
    vertex_position=cur_position + vert_dist*(Point(v1) - Point(0.0, 2.0)),
    vertex=[lines1;], vertex_kwargs = (;fill_color="black"))

    tikz_str *= tikz(
    graph;
    vertex_position=v -> cur_position + vert_dist*(Point(v) - Point(0.0, 2.0)), 
    vertex = v -> iseven(v[2]) ? [L"\Gamma_{v}", circ, sqrt(2)*lvec] : [L"\Gamma^{*}_{v}", circ, sqrt(2)*lvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(2.75, 0.0), vertex = [L"\Lambda_{v, v + 1}", Circle(Point(0.0, 0.0), 0.425)], 
    vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(2.75, -vert_dist), vertex = [L"\Lambda_{v, v + 1}", Circle(Point(0.0, 0.0), 0.425)], 
    vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(4, -vert_dist/2), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(5.5, -vert_dist/2),
    vertex=[[
        LineString([Point(-1.25, -vert_dist/2), Point(0.0, -vert_dist/2), Point(0.0, 0.0), Point(0.0, vert_dist/2), Point(-1.25, vert_dist/2)]),
        ];],
    ) 
    save(PDF(save_root*"RightVidalIsometryMPS"), TikzPicture(tikz_str))


end

#Define the SVD of $M_{v,v}^{.5}M_{v,v}^{.5}%
function SVD_RootM()
    graph = named_grid((2,1))
    cur_position = Point2(0.0, 0.0)

    tikz_str = tikz(graph; 
    vertex_position= v-> cur_position + 1.4Point2(v) - 1.4Point2(0.0, 1.0),
    vertex = v-> isodd(v[1]) ? [L"M^{\frac{1}{2}}_{v, v_{i}}", circ,lvec] : [L"M^{\frac{1}{2}}_{v_{i}, v}", circ, rvec],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size)
    )

    tikz_str *= tikz(; vertex_position=cur_position + Point(5.0, 0.0), vertex = [L"\approx"], vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"{\rm SVD}"], vertex_position=cur_position + Point(5.0, 0.5), vertex_kwargs = (; text_size = "\\normalsize"))

    graph = named_grid((3,1))
    cur_position = cur_position + Point(6.0, 0.0)


    tikz_str *= tikz(graph; vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v-> v[1] == 1 ? [L"U_{v, v_{i}}", right_triangle, lvec] : v[1] == 3 ? [L"V_{v_{i}, v}", left_triangle,  rvec] : [L"\Lambda_{v, v_{i}}", s_circ],
    vertex_kwargs = v -> v[1] == 2 ? (; fill_color = "black", text_size = bt_label_size) : (; fill_color = "orange", text_size = mt_label_size))

    save(PDF(save_root*"SVD_RootMessageTensors"), TikzPicture(tikz_str))

end

#Define \Gamma_{v}
function Gamma()
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position, vertex = [L"\Gamma_{v}", circ,  dvec, rvec, lvec, Vec(-1/sqrt(2), 1/sqrt(2)) ], vertex_kwargs = (; fill_color = "blue" ))


    tikz_str *= "\\draw [dotted, line width = 1pt] (0.65, 0.0) arc [start angle = 0, end angle = 135, x radius = 0.7cm, y radius = 0.7cm];"

    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(2.5, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    graph = named_grid((5,1))
    cur_position = cur_position + Point(3.5, 0.0)

    vertex_dict = Dict([((1,1), [L"V_{v_{1}, v}", left_triangle, lvec]), ((2,1), [L"M^{\frac{1}{2}}_{v, v_{1}}", circ]), ((3,1), [L"T_{v}", circ, dvec, Vec(-2.5,2.5)]), ((4,1),[L"M^{-\frac{1}{2}}_{v, v_{N}}", circ]), ((5,1), [L"U_{v, v_{N}}", right_triangle, rvec])])
    tikz_str *= tikz(graph; vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)), vertex = v -> vertex_dict[v], 
    vertex_kwargs = v -> v[1] == 1 || v[1] == 5 ? (; fill_color = "orange", text_size = mt_label_size) : v[1] == 3 ? (; fill_color = "blue") : (; fill_color = "black", text_size = mt_label_size))

    rotated_triangle = rotate(left_triangle, -pi/4)

    tikz_str *= tikz(; vertex_position = cur_position + Point(4.2, 0.0) + Point(-1.1, 1.1), vertex = [L"M^{-\frac{1}{2}}_{v,v_{2}}", circ], vertex_kwargs = (;fill_color = "black", text_size = mt_label_size))

    tikz_str *= "\\draw [dotted, line width = 1pt] (9.1, 0.5) arc [start angle = 0, end angle = 140, x radius = 1.2cm, y radius = 1.2cm];"

    tikz_str *= tikz(; vertex_position = cur_position + Point(4.2, 0.0) + Point(-2, 2), vertex =[L"V_{v,v_{2}}", rotated_triangle], vertex_kwargs = (; fill_color = "orange", text_size =mt_label_size))
    
    save(PDF(save_root*"Gamma"), TikzPicture(tikz_str))
end

#Define \Lambda_{v, v}
function Lambda()
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position,
    vertex = [L"\Lambda_{v, v_{i}}", s_circ, lvec, rvec],
    vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(2.5, 0.0), vertex_kwargs = (;text_size = "\\Large"))

    graph = named_grid((4,1))
    cur_position = cur_position + Point(4.0, 0.0)

    vert_dict = Dict([((1,1), [L"U_{v, v_{i}}", left_triangle,  lvec]), ((2,1), [L"M^{\frac{1}{2}}_{v, v_{i}}", circ]), ((3,1), [L"M^{\frac{1}{2}}_{v_{i}, v}", circ]), ((4,1), [L"V_{v_{i}, v}",right_triangle, rvec])])
    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> vert_dict[v],
    vertex_kwargs = v->v[1] == 1 || v[1] == 4 ? (; fill_color = "orange", text_size = mt_label_size) : (; fill_color = "black", text_size = mt_label_size))

    save(PDF(save_root*"Lambda"), TikzPicture(tikz_str))

end

#Define Gauged TNS equaivalent to ungauged TNS
function vidal_gauge_TNS()
    cur_position = zeros(Point2)

    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))
    positions = spring(graph)

    tikz_str = tikz(graph; vertex_position=v-> cur_position + 1.5positions[v], vertex =v-> [L"T_{%$(v[1])}", circ, dvec], vertex_kwargs = (; fill_color = "blue"))
    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(5.0, 0.0), vertex_kwargs = (; text_size = "\\large"))

    cur_position = cur_position + Point(8.0, 0.0)

    tikz_str *= tikz(graph;vertex_position=v-> cur_position + 1.5positions[v], vertex = v-> (v == 5 || v == 1) ? [L"\Gamma_{%$(v[1])}", circ, 0.7*dvec] : [L"\Gamma_{%$(v[1])}", circ, dvec], vertex_kwargs = (; fill_color = "blue"),
        edge=e ->[L"\Lambda_{%$(src(e)[1]),%$(dst(e)[1])}",s_circ, Line],edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")])

    save(PDF(save_root*"VidalGaugeTNS"), TikzPicture(tikz_str))
end

#ApproximateIsometryTNS
function ApproximateIsometryTNS()
    cur_position = zeros(Point2)
    graph = named_grid((1,2))
    v1, v2 = vertices(graph)[1], vertices(graph)[2]

    shift = 0.5
    lines1 = [
        LineString([Point(0.0, 0.0), Point(-2.0, shift), Point(-2.0, 2.0 + shift), Point(0.0, 2.0)]),
        ]
    
    lines2 = [
    LineString([Point(0.0, 0.0), Point(-2.3, -shift), Point(-2.3, -2 - shift), Point(0.0, -2.0)]),
    ]
    tikz_str = tikz(;
    vertex_position=cur_position + 2(Point(v1) - Point(0.0, 2.0)), vertex = [lines1;], vertex_kwargs = (; fill_color = "black"))
    tikz_str *= tikz(;
    vertex_position=cur_position + 2(Point(v2) - Point(0.0, 2.0)), vertex = [lines2;], vertex_kwargs = (; fill_color = "black"))


    cur_position = zeros(Point2)

    tikz_str *= tikz(
    graph; vertex_position=v -> cur_position + 2(Point(v) - Point(0.0, 2.0)), 
    vertex = v-> iseven(v[2]) ? [L"\Gamma_{v}", circ, sqrt(2)*rvec] : [L"\Gamma^{*}_{v}", circ, sqrt(2)*rvec],
    vertex_kwargs = (; fill_color = "blue"))


    tikz_str *= "\\draw [dotted, line width = 1pt] (2.75, 0.0) arc [start angle = 0, end angle = 155, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= "\\draw [dotted, line width = 1pt] (2.75, -2) arc [start angle = 0, end angle = -155, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex = [L"\approx"], vertex_position=cur_position + Point(4.0, -1.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex = [L"\lambda_{v,v_{i}}"], vertex_position=cur_position + Point(4.75, -1.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position=cur_position + Point(5.4, -1.0),
    vertex=[[
        LineString([Point(1.0, -1.0), Point(0.0, -1.0), Point(0.0, 0.0), Point(0.0, 1.0), Point(1.0, 1.0)]),
        ];],
    )

    save(PDF(save_root*"ApproximateIsometryTNS"), TikzPicture(tikz_str))
end

#Canonicalness Definition
function canonicalness()

    cur_position = zeros(Point2)

    tikz_str = tikz(; vertex = [L"\mathcal{C}"], vertex_position=cur_position + Point(0, -1) , vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(1.0, -1), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex = [L"\frac{1}{2 \vert E \vert}"], vertex_position=cur_position + Point(2.0, -1), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex = [L"\sum_{v}"], vertex_position=cur_position + Point(2.75, -1), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex = [L"\sum_{i = 1}^{\vert N(v) \vert }"], vertex_position=cur_position + Point(4.1, -0.9), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point2(3.0, 0.0)

    l1 = [LineString([Point(2.0, -2.5), Point(2.0, 0.5)])]
    tikz_str *= tikz(;vertex_position=cur_position, vertex = [l1;], vertex_kwargs = (; line_thickness = 1))
    tikz_str *= tikz(;vertex_position=cur_position + Point(0.25, 0.0), vertex = [l1;], vertex_kwargs = (; line_thickness = 1))

    cur_position += Point2(3.0, 0.0)

    graph = named_grid((1,2))
    v1, v2 = vertices(graph)[1], vertices(graph)[2]

    shift = 0.5
    lines1 = [
        LineString([Point(0.0, 0.0), Point(-2.0, shift), Point(-2.0, 2.0 + shift), Point(0.0, 2.0)]),
        ]
    
    lines2 = [
    LineString([Point(0.0, 0.0), Point(-2.3, -shift), Point(-2.3, -2 - shift), Point(0.0, -2.0)]),
    ]

    tikz_str *= "\\draw [dotted, line width = 1pt] (8.75, 0.0) arc [start angle = 0, end angle = 150, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= "\\draw [dotted, line width = 1pt] (8.75, -2) arc [start angle = 0, end angle = -150, x radius = 0.825cm, y radius = 0.825cm];"

    tikz_str *= tikz(;
    vertex_position=cur_position + 2(Point(v1) - Point(0.0, 2.0)), vertex = [lines1;], vertex_kwargs = (; fill_color = "black"))
    tikz_str *= tikz(;
    vertex_position=cur_position + 2(Point(v2) - Point(0.0, 2.0)), vertex = [lines2;], vertex_kwargs = (; fill_color = "black"))

    tikz_str *= tikz(
    graph; vertex_position=v -> cur_position + 2(Point(v) - Point(0.0, 2.0)), 
    vertex = v-> iseven(v[2]) ? [L"\Gamma_{v}", circ, sqrt(2)*rvec] : [L"\Gamma^{*}_{v}", circ, sqrt(2)*rvec],
    vertex_kwargs = (; fill_color = "blue"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.5, 0.4),
    vertex=[L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, 0.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(;vertex_position=cur_position + Point(2.0, -2.0) + Point(-1.8, -0.35),
    vertex=[L"\Lambda_{v_{N},v}", s_circ], vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex = [L"-"], vertex_position=cur_position + Point(4.0, -1.0), vertex_kwargs = (; text_size = "\\Large"))


    tikz_str *= tikz(;
    vertex_position=cur_position + Point(5.0, -1.0),
    vertex=[[
        LineString([Point(1.0, -1.0), Point(0.0, -1.0), Point(0.0, 0.0), Point(0.0, 1.0), Point(1.0, 1.0)]),
        ];],
    )

    cur_position += Point(6.5, 0.0)
    l1 = [LineString([Point(0.0, -2.5), Point(0.0, 0.5)])]
    tikz_str *= tikz(;vertex_position=cur_position, vertex = [l1;], vertex_kwargs = (; line_thickness = 1))
    tikz_str *= tikz(;vertex_position=cur_position + Point(0.25, 0.0), vertex = [l1;], vertex_kwargs = (; line_thickness = 1))
    tikz_str *= tikz(; vertex = [L"1"], vertex_position=cur_position + Point(0.5, -2.5), vertex_kwargs = (; text_size = "\\Large"))

    save(PDF(save_root*"Canonicalness"), TikzPicture(tikz_str))
end

#Approx Sz measurement
function approx_Sz()

    s_square = Polygon([Point2(-0.35, -0.35), Point2(-0.35, 0.35), Point2(0.35, 0.35), Point2(0.35, -0.35)])

    graph = named_grid((1,3))

    cur_position = zero(Point2)
    sf = sqrt(2)

    l1 = [
        LineString([Point(1.0, 3), Point(2.5, 3), Point(2.5, 1), Point(1.0, 1)]),
        ]

    l2 = [
    LineString([Point(1.0, 3), Point(-0.5, 3), Point(-0.5, 1), Point(1.0, 1)]),
    ]

    l3 = [
        LineString([Point(1.0, 3), Point(1.75, 3.5), Point(1.75, 1.5), Point(1.0, 1)]),
        ]

    
    l4 = [
        LineString([Point(1.0, 3), Point(0.25, 2.5), Point(0.25, 0.5), Point(1.0, 1)]),
        ]
        
    

    tikz_str = tikz(;
    vertex_position=v-> cur_position + Point2(0.0, 2.0),
    vertex = v -> [L"\langle S^{z}_{v} \rangle"], vertex_kwargs = (; text_size = "\\Large")
    )

    ss_circ = Circle(Point(0.0, 0.0), 0.35)

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(0.75, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point2(2.0, 0.0)

    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l1;])
    tikz_str *= tikz(;
    
    vertex_position=cur_position, vertex = [l2;])

    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l3;])

    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l4;])

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(0.25, 1.5), vertex = [L"\Lambda^{2}_{v_{4},v}", ss_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    #Step 1
    tikz_str *= tikz(graph ;
    vertex_position=v-> cur_position + 1.0*Point(v),
    vertex = v -> v[2] == 3 ? [L"\Gamma_{v}", circ] : v[2] == 1 ? [L"\Gamma^{*}_{v}", circ] : [L"S^{z}_{v}", s_square],
    vertex_kwargs = v -> isodd(v[2]) ? (; fill_color = "blue!150!") : (; fill_color = "orange") ,
    )

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(-0.5, 2), vertex = [L"\Lambda^{2}_{v_{1},v}", ss_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(2.5, 2), vertex = [L"\Lambda^{2}_{v_{2},v}", ss_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.75, 2.5), vertex = [L"\Lambda^{2}_{v_{3},v}", ss_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))


    save(PDF(save_root*"ApproxSz"), TikzPicture(tikz_str))

    t_circ = Circle(Point(0.0, 0.0), 0.45)
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position,
    vertex = [L"\Lambda^{2}_{v, v_{i}}", t_circ, lvec, rvec],
    vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(1.75, 0.0), vertex_kwargs = (;text_size = "\\Large"))

    graph = named_grid((2,1))
    cur_position = cur_position + Point(2.0, 0.0)

    vert_dict = Dict([((1,1), [L"\Lambda_{v, v_{i}}", t_circ,  lvec]), ((2,1), [L"\Lambda_{v, v_{i}}", t_circ,  rvec]) ])
    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> vert_dict[v],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    save(PDF(save_root*"SquareBondTensors"), TikzPicture(tikz_str))

end

function PEPO_Contraction()

    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))

    cur_position = zeros(Point2)

    #General Network
    positions = spring(graph)
    positions[4] += Point2(1, -0.75)
    positions[3] -= Point2(0.5, 0.5)
    rem_edges!(graph, [3=>5])
    
    l1 = [LineString([Point(3, 0) + 1.5*positions[i], Point(3, 4) + 1.5*positions[i]]) for i in 1:6]
    tikz_str = tikz(;
        vertex_position=cur_position, vertex = [l1;], vertex_kwargs = (; line_style = "dashed"))
        l1 = [LineString([Point(3, 0) + 1.5*positions[1], Point(3, 4) + 1.5*positions[1]])]

    tikz_str *= tikz(; vertex=[L"D"], vertex_position=cur_position + Point(3, 4.5) +  .75positions[2] + .75positions[4], vertex_kwargs = (;text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\chi"], vertex_position=cur_position + Point(3, 0.5) +  .75positions[2] + .75positions[4], vertex_kwargs = (;text_size = "\\Large"))

    tikz_str *= tikz(; vertex=[L"\mathbf{i)}"], vertex_position= Point2(0.0, 5.0), vertex_kwargs = (;text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\mathbf{ii)}"], vertex_position= Point2(10.0, 5.0), vertex_kwargs = (;text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\mathbf{iii)}"], vertex_position= Point2(20.0, 5.0), vertex_kwargs = (;text_size = "\\Large"))

    tikz_str *= tikz(graph;vertex_position=v-> cur_position + Point(3, 0) +  1.5positions[v], vertex = v-> [L"T_{%$(v)}", circ, uvec],vertex_kwargs = (; fill_color = "blue"))

    cur_position += Point2(0, 4.0)
    tikz_str *= tikz(graph;vertex_position=v-> cur_position + Point(3, 0) +  1.5positions[v], vertex = v-> [L"O_{%$(v)}", circ, uvec, dvec],vertex_kwargs = (; fill_color = "black"))

    cur_position += Point2(10.0, -2.0)
    tikz_str *= tikz(graph;vertex_position=v-> cur_position + Point(3, 0) +  1.5positions[v], vertex = v-> [L"\tilde{T}_{%$(v)}", circ, uvec],vertex_kwargs = (; fill_color = "blue"), edge_kwargs = (; line_thickness = 3.2))

    tikz_str *= tikz(; vertex=[L"D \chi"], vertex_position=cur_position + Point(2.8, 0.5) +  .75positions[2] + .75positions[4], vertex_kwargs = (;text_size = "\\Large"))

    tikz_str *= tikz(; vertex=[L"\approx"], vertex_position=cur_position + Point(9.0, 1.0), vertex_kwargs = (;text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"{\rm BPG}"], vertex_position=cur_position + Point(9.0, 1.5), vertex_kwargs = (;text_size = "\\Large"))
    cur_position += Point2(10.0, 0.0)

    tikz_str *= tikz(graph;vertex_position=v-> cur_position + Point(3, 0) +  1.5positions[v], vertex = v-> [L"\Gamma_{%$(v)}", circ, uvec],vertex_kwargs = (; fill_color = "blue"),
        edge=e ->[L"\Lambda_{%$(src(e)),%$(dst(e))}",s_circ, Line], edge_kwargs = (; fill_color = 
        "black"))
    save(PDF(save_root*"TNSTNOContraction"), TikzPicture(tikz_str))

end
function root_bond_tensors()
    #Define \Lambda_{i}
    t_circ = Circle(Point(0.0, 0.0), 0.45)
    cur_position = Point(0.0, 0.0)

    tikz_str = tikz(; 
    vertex_position= cur_position,
    vertex = [L"\Lambda_{v, v_{i}}", t_circ, lvec, rvec],
    vertex_kwargs = (; text_size = bt_label_size, fill_color = "black"))

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(1.75, 0.0), vertex_kwargs = (;text_size = "\\Large"))

    graph = named_grid((2,1))
    cur_position = cur_position + Point(2.0, 0.0)

    vert_dict = Dict([((1,1), [L"\Lambda^{1/2}_{v, v_{i}}", t_circ,  lvec]), ((2,1), [L"\Lambda^{1/2}_{v,v_{i}}", t_circ,  rvec]) ])
    tikz_str *= tikz(graph; 
    vertex_position= v-> cur_position + 1.4*(Point(v) - Point(0.0, 1.0)),
    vertex = v -> vert_dict[v],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    save(PDF(save_root*"RootBondTensors"), TikzPicture(tikz_str))
end

function symmetric_tensor()
    cur_position = zeros(Point2)
    #Part 1
    tikz_str = tikz(
    ; vertex_position = cur_position, vertex = v-> [L"\Gamma_{v}", circ, dvec, 1.5*rvec, 2*lvec, 1.5*(lvec + uvec), 2*(rvec + Point2(0.0, 0.75)), 2*(rvec + Point2(0.0, -0.75))],
    vertex_kwargs = (; fill_color = "blue", line_thickness = 3.2))

    tikz_str *= tikz(; vertex_position = cur_position + 0.8*Point(-1.5, 0.0), vertex = [L"\Lambda^{1/2}_{v_{N}, v}", circ],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(;  vertex_position = cur_position + 0.8*Point(-1.3, 1.3), vertex = [L"\Lambda^{1/2}_{v_{1}, v}", circ],
    vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(; vertex_position = cur_position + 0.8*sqrt(2)*Point(1.0, 0.75),
    vertex = [L"\Lambda^{1/2}_{v_{i-1}, v}", circ], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    tikz_str *= tikz(; vertex_position = cur_position + 0.8*sqrt(2)*Point(1.0, -0.75),
    vertex = [L"\Lambda^{1/2}_{v_{i+1}, v}", circ], vertex_kwargs = (; fill_color = "black", text_size = mt_label_size))

    points = generate_arc(Point2(-1, 0.5), Point2(0.3, -0.4), 0.8; theta_shift = 2.5, npoints = 5)
    lines = [
      LineString(points),
    ]

    tikz_str *= "\\draw [dotted, line width = 1pt] (0.6, -0.6) arc [start angle = -45, end angle = -170, x radius = 0.825cm, y radius = 0.825cm];"


    tikz_str *= "\\draw [dotted, line width = 1pt] (0.6, 0.6) arc [start angle = 45, end angle = 130, x radius = 0.9cm, y radius = 0.9cm];"

    tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(2.75, 0.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(;
    vertex_position = cur_position + Point(5.0, 0.0), vertex = [L"S_{v}", circ, dvec, rvec, lvec, (lvec + uvec), (rvec + Point2(0.0, 0.75)), (rvec + Point2(0.0, -0.75))],
    vertex_kwargs = (; fill_color = "blue", line_thickness = 3.2))

    save(PDF(save_root*"SymmetricTensor"), TikzPicture(tikz_str))
end

#Define Gauged TNS equaivalent to ungauged TNS
function symmetric_tensor_network_state()
    cur_position = zeros(Point2)

    Random.seed!(1234)
    graph = NamedGraph(random_regular_graph(6,3))
    positions = spring(graph)
    tikz_str = tikz(graph;vertex_position=v-> cur_position + 1.5positions[v], vertex = v-> (v == 5 || v == 1) ? [L"\Gamma_{%$(v[1])}", circ, 0.7*dvec] : [L"\Gamma_{%$(v[1])}", circ, dvec], vertex_kwargs = (; fill_color = "blue"),
        edge=e ->[L"\Lambda_{%$(src(e)[1]),%$(dst(e)[1])}",s_circ, Line],edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")])

    tikz_str *= tikz(; vertex = [L"="], vertex_position=cur_position + Point(5.0, 0.0), vertex_kwargs = (; text_size = "\\large"))

    cur_position = cur_position + Point(8.0, 0.0)
    tikz_str*= tikz(graph; vertex_position=v-> cur_position + 1.5positions[v], vertex =v-> [L"S_{%$(v[1])}", circ, dvec], vertex_kwargs = (; fill_color = "blue"))
    

    save(PDF(save_root*"SymmetricTNS"), TikzPicture(tikz_str))
end


function infinite_TNS()
    #PEPS
    cur_position = zeros(Point2)
    graph = named_grid((6,6))
    tikz_str = tikz(; vertex=[L"\textbf{i)}"], vertex_position=cur_position + Point(3.0, -5.0), vertex_kwargs = (; text_size = "\\huge"))
    tikz_str *= tikz(graph;vertex_position=v->cur_position + Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)), 
    vertex = v-> [circ, dvec, 0.7*lvec, 0.7*rvec, 0.7*Vec(-0.56, 0.8), 0.7*Vec(0.56, -0.8)],    vertex_kwargs = v -> (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,1)  ?  (; fill_color = "blue") : 
    (1 + (v[1] % 2), 1 + (v[2] % 2)) == (2,1) ? (; fill_color = "orange") : (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,2) ? (; fill_color = "red") :
    (; fill_color = "green"))

    cur_position += Point2(14.0, -1.0)
    graph = named_grid((2,2))
    shift = 1.5

    tikz_str *= tikz(; vertex=[L"\textbf{ii)}"], vertex_position=cur_position + Point(1.0, -0.0), vertex_kwargs = (; text_size = "\\huge"))
    tikz_str *= tikz(; vertex=[L"\textbf{iii)}"], vertex_position=cur_position + Point(4.5, -4.5), vertex_kwargs = (; text_size = "\\huge"))
    vp = [Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)) for v in vertices(graph)]
    l1 = [
        LineString([vp[1], vp[1] + Point(-1.5, 0.0), vp[1] + Point(-1.5, 1.0), vp[2] + Point(1.5, 1.0), vp[2] + Point(1.5, 0.0), vp[2]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l1;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    l2 = [
        LineString([vp[3], vp[3] + Point(-1.5, 0.0), vp[3] + Point(-1.5, 0.8), vp[4] + Point(1.5, 0.8), vp[4] + Point(1.5, 0.0), vp[4]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l2;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    l3 = [
        LineString([vp[1], vp[1] + Point(-0.75, 1.0), vp[1] + Point(-0.75, 2.1), vp[3] + Point(1.0, 0.0), vp[3] + Point(1.0, -1.5), vp[3]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l3;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))


    l4 = [
        LineString([vp[2], vp[2] + Point(-0.75, 1.0), vp[2] + Point(-0.75, 2.1), vp[4] + Point(1.0, 0.0), vp[4] + Point(1.0, -1.5), vp[4]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l4;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    tikz_str *= tikz(graph;vertex_position=v->cur_position + Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)), 
    vertex = v-> [circ, dvec],    vertex_kwargs = v -> (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,1)  ?  (; fill_color = "blue") : 
    (1 + (v[1] % 2), 1 + (v[2] % 2)) == (2,1) ? (; fill_color = "orange") : (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,2) ? (; fill_color = "red") :
    (; fill_color = "green"))

    cur_position += Point2(3.5, -4.5)
    graph = named_grid((2,2))
    shift = 1.5

    vp = [Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)) for v in vertices(graph)]
    l1 = [
        LineString([vp[1], vp[1] + Point(-1.5, 0.0), vp[1] + Point(-1.5, 1.0), vp[2] + Point(1.5, 1.0), vp[2] + Point(1.5, 0.0), vp[2]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l1;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    l2 = [
        LineString([vp[3], vp[3] + Point(-1.5, 0.0), vp[3] + Point(-1.5, 0.8), vp[4] + Point(1.5, 0.8), vp[4] + Point(1.5, 0.0), vp[4]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l2;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    l3 = [
        LineString([vp[1], vp[1] + Point(-0.75, 1.0), vp[1] + Point(-0.75, 2.1), vp[3] + Point(1.0, 0.0), vp[3] + Point(1.0, -1.5), vp[3]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l3;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))


    l4 = [
        LineString([vp[2], vp[2] + Point(-0.75, 1.0), vp[2] + Point(-0.75, 2.1), vp[4] + Point(1.0, 0.0), vp[4] + Point(1.0, -1.5), vp[4]]),
        ]
    
    tikz_str *= tikz(;
    vertex_position=cur_position, vertex = [l4;], vertex_kwargs = (; fill_color = "black", line_style = "dashed"))

    ss_circ = Circle(Point(0.0, 0.0), 0.2)
    tikz_str *= tikz(graph;vertex_position=v->cur_position + Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)), 
    vertex = v-> [circ, dvec],    vertex_kwargs = v -> (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,1)  ?  (; fill_color = "blue!150!") : 
    (1 + (v[1] % 2), 1 + (v[2] % 2)) == (2,1) ? (; fill_color = "orange!150!") : (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,2) ? (; fill_color = "red!150!") :
    (; fill_color = "green!150!"),
    edge = [ss_circ; Line], edge_kwargs = (; fill_color = "black"))

    graph = named_grid((6,6))
    cur_position = Point(20.0, 0.0)
    tikz_str *= tikz(; vertex=[L"\textbf{iv)}"], vertex_position=cur_position + Point(3.5, -5.0), vertex_kwargs = (; text_size = "\\huge"))
    tikz_str *= tikz(graph;vertex_position=v->cur_position + Point(2, -2/√2) * (Point(v) + Point(v[2]/2, 0)), 
    vertex = [circ, dvec, 0.7*lvec, 0.7*rvec, 0.7*Vec(-0.56, 0.8), 0.7*Vec(0.56, -0.8)],    vertex_kwargs = v -> (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,1)  ?  (; fill_color = "blue!150!") : 
    (1 + (v[1] % 2), 1 + (v[2] % 2)) == (2,1) ? (; fill_color = "orange!150!") : (1 + (v[1] % 2), 1 + (v[2] % 2)) == (1,2) ? (; fill_color = "red!150!") :
    (; fill_color = "green!150!"),
    edge = [ss_circ; Line], edge_kwargs = (; fill_color = "black"))


    save(PDF(save_root*"InfiniteTNS"), TikzPicture(tikz_str))
end

# example_TNSs()
# isometry_condition()
# norm_tensor()
# belief_propagation_diagrams()
# belief_propagation_MPS()
# MPSBeliefPropagationidentity()
# SVD_RootM_MPS()
# UV_isometries()
# Lambda_MPS()
# Gamma_MPS()
# vidal_gauge_isometries_MPS()
# vidal_gauge_MPS()
# SVD_RootM()
Gamma()
Lambda()
vidal_gauge_TNS()
ApproximateIsometryTNS()
canonicalness()
approx_Sz()
PEPO_Contraction()
root_bond_tensors()
symmetric_tensor()
symmetric_tensor_network_state()
infinite_TNS()