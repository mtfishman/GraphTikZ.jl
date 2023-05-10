using GeometryBasics
using Graphs
using LaTeXStrings
using NamedGraphs
using TikzPictures
using GraphTikZ

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

using NamedGraphs: rem_edges!, steiner_tree, random_bfs_tree

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

rect = Polygon([Point2(-2*polygon_dist, -polygon_dist), Point2(-2*polygon_dist, polygon_dist), Point2(2*polygon_dist, polygon_dist), Point2(2*polygon_dist, -polygon_dist)])

function rotate_polygon(P::Polygon, θ::Float64)
    rotate_mat = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    return Polygon([Point2(rotate_mat*c) for c in coordinates(P)])
end

#Steps to perform a simple update Gauging of a bond.
function SimpleUpdate()
    graph = named_grid((2,1))

    cur_position = zero(Point2)
    sf = 1.2

    #Step 1
    tikz_str = tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v) + Point(0, 0),
    vertex = v -> isodd(v[1]) ? [L"\Gamma_{v}", circ, 2.5*dvec, sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)] : [L"\Gamma_{w}", circ, 2.5*dvec, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[L"\Lambda_{v,w}",s_circ, Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )

    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, 1.2) -- (4.25, 1.2);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, 1.2) -- (1.75, -0.8);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, -0.8) -- (4.25, -0.8);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (4.25, 1.2) -- (4.25, -0.8);"

    tikz_str *= tikz(; vertex=[L"\textbf{i)}"], vertex_position=cur_position + Point(0.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{ii)}"], vertex_position=cur_position + Point(6.5, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{iii)}"], vertex_position=cur_position + Point(13.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex_position = v-> cur_position + Point(3, 0.5), vertex = [L"O_{v,w}", Polygon([Point(1.2, 0.5), Point(1.2, -0.5), Point(-1.2, -0.5), Point(-1.2, 0.5)])], vertex_kwargs = (; fill_color = "orange"))

    lines = [
        LineString([Point(0.6, 0), Point(0.6,-1)]),
        LineString([Point(-0.6, 0), Point(-0.6,-1)])
        ]

    cur_position += Point(9.0, 2.0)
    tikz_str *= tikz(; vertex_position = cur_position, vertex = [[L"\Theta_{v,w}", Polygon([Point(1.2, 0.5), Point(1.2, -0.5), Point(-1.2, -0.5), Point(-1.2, 0.5)]), 2.1*rvec, 1.8*Vec(1.0, 0.2), 1.8*Vec(1.0, -0.2), 1.8*Vec(-1.0, -0.2),
        1.8*Vec(-1.0, 0.2)]; lines],  vertex_kwargs = (; fill_color = "orange"))
       

    tikz_str *= tikz(; vertex=[L"{\rm SVD}"], vertex_position=cur_position + Point(3.0, 0.5), vertex_kwargs = (; text_size = "\\normalsize"))
    tikz_str *= tikz(; vertex=[L"\approx"], vertex_position=cur_position + Point(3.0, 0.0), vertex_kwargs = (; text_size = "\\Large"))
    cur_position += Point(3.5, -2)

    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> isodd(v[1]) ? [L"U_{v}", right_triangle, dvec, Vec(-1.0, -1.0), Vec(-1.0, 1.0)] : [L"V_{w}",left_triangle, dvec, Vec(1.0, -1.0), Vec(1.0, 1.0), Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "orange"),
    edge=e ->[L"\tilde{\Lambda}_{v,w}",Circle(Point(0.0, 0.0), 0.4), Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )

    cur_position = Point(4.5, -5)

    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v) + Point(-2, 0),
    vertex = v -> isodd(v[1]) ? [L"U_{v}", right_triangle, dvec, 2*Vec(-1.0, -1.0), 2*Vec(-1.0, 1.0)] : [L"V_{w}", left_triangle, dvec, 2*Vec(1.0, -1.0), 2*Vec(1.0, 1.0), 2*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "orange"),
    edge=e ->[L"\tilde{\Lambda}_{v,w}",Circle(Point(0.0, 0.0), 0.4), Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )


    tikz_str *= tikz(; vertex=[L"\textbf{iv)}"], vertex_position=cur_position + Point(-1.5, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{v)}"], vertex_position=cur_position + Point(6.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position = cur_position + Point(-2, 0)

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda^{-1}_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda^{-1}_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda^{-1}_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda^{-1}_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda^{-1}_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(0.6, 0.6), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(0.6, 3.4), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.5, 0.6), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.5, 3.5), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(6.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    cur_position = cur_position + Point(8, 0)

    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> isodd(v[1]) ? [L"\widetilde{\Gamma}_{v}", circ, dvec, sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)] : [L"\widetilde{\Gamma}_{w}", circ,dvec, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[L"\tilde{\Lambda}_{v,w}",Circle(Point(0.0, 0.0), 0.4), Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    save(PDF(save_root*"SimpleUpdate"), TikzPicture(tikz_str))

end


#Steps to perform a simple update Gauging of a bond.
function SimpleUpdateQR()
    graph = named_grid((2,1))

    cur_position = zero(Point2)
    sf = 1.2

    #Step 1
    tikz_str = tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v) + Point(0, 0),
    vertex = v -> isodd(v[1]) ? [L"\Gamma_{v}", circ, 2.5*dvec, sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)] : [L"\Gamma_{w}", circ, 2.5*dvec, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[L"\Lambda_{v,w}",s_circ, Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )

    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, 1.2) -- (4.25, 1.2);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, 1.2) -- (1.75, -0.8);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (1.75, -0.8) -- (4.25, -0.8);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (4.25, 1.2) -- (4.25, -0.8);"

    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (8.25, 1.0) -- (11.75, 1.0);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (8.25, 1.0) -- (8.25, -1.0);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (8.25, -1.0) -- (11.75, -1.0);"
    tikz_str *= "\\draw [dotted, line width = 1pt, color=red] (11.75, 1.0) -- (11.75, -1.0);"

    tikz_str *= tikz(; vertex=[L"r"], vertex_position=Point(10.0, 0.4), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\chi"], vertex_position=Point(10.0, 2.4), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"r\chi"], vertex_position=Point(17.0, 2.4), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex=[L"\textbf{i)}"], vertex_position=cur_position + Point(0.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{ii)}"], vertex_position=cur_position + Point(7.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{iii)}"], vertex_position=cur_position + Point(13.5, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex_position = v-> cur_position + Point(3, 0.5), vertex = [L"O_{v,w}", Polygon([Point(1.2, 0.5), Point(1.2, -0.5), Point(-1.2, -0.5), Point(-1.2, 0.5)])], vertex_kwargs = (; fill_color = "orange"))



    cur_position += Point(7.0, -2.0)

    vert_dict = Dict([((1,2), [L"\Gamma_{v}^{'}", circ,sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)]), ((2,2), [L"\Gamma_{w}^{'}", circ, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)]),
            ((1,1), [L"O_{v}", circ, dvec]), ((2,1), [L"O_{w}", circ, dvec])])
    graph = named_grid((2,2))
    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> vert_dict[v],
    vertex_kwargs = v-> v[2] == 2 ? (; fill_color = "blue") :  (; fill_color = "orange")
    )

    #tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(7.0, 4.0), vertex_kwargs = (; text_size = "\\Large"))

    cur_position += Point(7.0, 2.0)


    vert_dict = Dict([((1,1), [L"\Gamma_{v}^{''}", circ,lvec]), ((2,1), [L"\Gamma_{w}^{''}", circ, rvec])])
    graph = named_grid((2, 1))
    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> vert_dict[v],
    vertex_kwargs = (; fill_color = "blue", line_line_thickness = 3.2),
    edge_kwargs = (; line_line_thickness = 3.2)
    )

    cur_position = Point2(0.0, -5.0)
    vert_dict = Dict([((1,1), [L"Q_{v}", right_triangle, lvec]), ((2,1), [L"R_{v}", circ]), ((3,1), [L"R_{w}", circ]), ((4,1), [L"Q_{w}", left_triangle, rvec])])
    graph = named_grid((4,1))
    es = edges(graph)
    tikz_str *= tikz(graph; vertex_position = v -> cur_position + 2.0*Point(v),
    vertex = v -> vert_dict[v],
    vertex_kwargs = (; line_line_thickness = 3.2, fill_color = "blue"),
    edge_kwargs = e -> (e == es[1] || e == es[3]) ? (; line_line_thickness = 1.6) : (; line_line_thickness = 3.2)
    )
    tikz_str *= tikz(; vertex=[L"\textbf{iv)}"], vertex_position=cur_position + Point(0.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{v)}"], vertex_position=cur_position + Point(11.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    #tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(11.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    cur_position += Point2(11.0, 0.0)

    vert_dict = Dict([((1,1), [L"Q_{v}", right_triangle, lvec]), ((2,1), [L"\Theta_{v,w}", rect]), ((3,1), [L"Q_{w}", left_triangle, rvec])])
    graph = named_grid((3,1))
    es = edges(graph)
    tikz_str *= tikz(graph; vertex_position = v -> cur_position + 2.0*Point(v),
    vertex = v -> vert_dict[v],
    vertex_kwargs =  v-> isodd(v[1]) ? (; line_line_thickness = 3.2, fill_color = "blue") : (; line_line_thickness = 3.2, fill_color = "orange")
    )

    cur_position = Point2(0.0, -9.0)

    tikz_str *= tikz(; vertex=[L"\textbf{vi)}"], vertex_position=cur_position + Point(0.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{vii)}"], vertex_position=cur_position + Point(11.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))

    tikz_str *= tikz(; vertex=[L"\chi^{'}"], vertex_position=cur_position + Point(4.25, 2.4), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\chi^{'}"], vertex_position=cur_position + Point(5.75, 2.4), vertex_kwargs = (; text_size = "\\Large"))
    vert_dict = Dict([((1,1), [L"Q_{v}", right_triangle, lvec]), ((2,1), [L"U_{v}", right_triangle]), ((3,1), [L"V_{w}", left_triangle]), ((4,1), [L"Q_{w}", left_triangle, rvec])])
    graph = named_grid((4,1))
    es = edges(graph)
    vertex_position_dict = Dict([((1,1), cur_position + Point(2.0, 2.0)), ((2,1), cur_position + Point(3.5, 2.0)),
    ((3,1), cur_position + Point(6.5, 2.0)), ((4,1), cur_position + Point(8.0, 2.0))])
    tikz_str *= tikz(graph; vertex_position = v -> vertex_position_dict[v],
    vertex = v -> vert_dict[v],
    vertex_kwargs = v-> v[1] == 1 || v[1] == 4 ? (; line_line_thickness = 3.2, fill_color = "blue") : (; line_line_thickness = 3.2, fill_color = "orange"),
    edge = e -> (e == es[2]) ? [[L"\tilde{\Lambda}_{v,w}", s_circ]; Line] : [Line],
    edge_kwargs = (; fill_color="black", line_line_thickness = 1.6, text_size = bt_label_size)
    )

    #tikz_str *= tikz(; vertex=[L"="], vertex_position=cur_position + Point(11.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    cur_position += Point2(11.0, 0.0)

    vert_dict = Dict([((1,1), [L"\Gamma_{v}^{'''}", circ,sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)]), ((2,1), [L"\Gamma_{w}^{'''}", circ, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)])])
    graph = named_grid((2,1))
    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> vert_dict[v],
    vertex_kwargs = (; fill_color = "blue"),
    edge = e -> [[L"\tilde{\Lambda}_{v,w}", s_circ]; Line],
    edge_kwargs = (; fill_color="black", line_line_thickness = 1.6,  text_size = bt_label_size))

    cur_position = Point2(4.0, -14.0)

    tikz_str *= tikz(; vertex=[L"\textbf{viii)}"], vertex_position=cur_position + Point(-4.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    tikz_str *= tikz(; vertex=[L"\textbf{ix)}"], vertex_position=cur_position + Point(7.0, 2.0), vertex_kwargs = (; text_size = "\\Large"))
    graph = named_grid((2,1))
    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v) + Point(-2, 0),
    vertex = v -> isodd(v[1]) ? [L"\Gamma_{v}^{'''}", circ, dvec, 2*Vec(-1.0, -1.0), 2*Vec(-1.0, 1.0)] : [L"\Gamma_{w}^{'''}", circ, dvec, 2*Vec(1.0, -1.0), 2*Vec(1.0, 1.0), 2*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[[L"\tilde{\Lambda}_{v,w}", Circle(Point(0.0, 0.0), 0.4)]; Line],
    edge_kwargs=(; fill_color="black", text_size = bt_label_size)
    )


    cur_position = cur_position + Point(-2, 0)

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda^{-1}_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda^{-1}_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda^{-1}_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda^{-1}_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda^{-1}_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(0.6, 0.6), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(0.6, 3.4), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.5, 0.6), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.5, 3.5), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(6.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))

    cur_position = cur_position + Point(10, 0)

    tikz_str *= tikz(
    graph;
    vertex_position=v-> cur_position + 2.0*Point(v),
    vertex = v -> isodd(v[1]) ? [L"\widetilde{\Gamma}_{v}", circ, dvec, sf*Vec(-1.0, -1.0), sf*Vec(-1.0, 1.0)] : [L"\widetilde{\Gamma}_{w}", circ,dvec, sf*Vec(1.0, -1.0), sf*Vec(1.0, 1.0), sf*Vec(sqrt(2),0)],
    vertex_kwargs = (; fill_color = "blue"),
    edge=e ->[L"\tilde{\Lambda}_{v,w}",Circle(Point(0.0, 0.0), 0.4), Line],
    edge_kwargs=[(; text_size=bt_label_size), (; fill_color="black")]
    )

    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 1.25), vertex = [L"\Lambda_{v_{2},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(1.25, 2.75), vertex = [L"\Lambda_{v_{1},v}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 1.25), vertex = [L"\Lambda_{w_{1},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(4.75, 2.75), vertex = [L"\Lambda_{w_{2},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))
    tikz_str *= tikz(; vertex_position=v-> cur_position + Point(5.25, 2.0), vertex = [L"\Lambda_{w_{3},w}", s_circ], vertex_kwargs = (; fill_color = "black", text_size = bt_label_size))


    save(PDF(save_root*"SimpleUpdateQR"), TikzPicture(tikz_str))

end


SimpleUpdate()
SimpleUpdateQR()