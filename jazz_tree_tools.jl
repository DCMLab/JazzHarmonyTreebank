include("Trees.jl")
using Trees
using LightGraphs
using LaTeXStrings
using TikzGraphs
using TikzPictures

function Base.length(table, i, j)
    @assert !isempty(table[i,j])
    l = 1
    while j+l <= size(table)[2] && isempty(table[i,j+l])
        l += 1
    end
    l
end

function create_tree_node(table, i, j)
    @assert !isempty(table[i,j])
    node = TreeNode(table[i,j])
    if i > 1
        for k in j:j+length(table, i, j)-1
            if !isempty(table[i-1, k])
                insert_child!(node, create_tree_node(table, i-1, k))
            end
        end
    end
    node
end

function trim_unary_chains!(tree)
    while length(tree.children) == 1 && tree.data == tree.children[1].data
        tree.children = tree.children[1].children
    end
    for child in tree.children
        trim_unary_chains!(child)
    end
    tree
end

function matrix_to_tree(table::Matrix)
    trim_unary_chains!(create_tree_node(table, size(table, 1), 1))
end

# print(csv_to_tree("flintstones.csv"))
#
# lines = split.(readlines("allofme.csv"), ';')
# skiplines = 2
# M = fill("", length(lines)-skiplines, length(lines[1]))
# for i in 1:length(lines)-skiplines
#     for j in eachindex(lines[i+skiplines])
#         str = replace(replace(lines[i+skiplines][j], "^7", "\\triangle"), "^", "")
#         if isempty(str)
#             continue
#         elseif '_' in str
#             scale_deg, key = split(str, '_')
#             M[i,j] = "\$\\text{$(scale_deg)}_{$(key)}\$"
#         else
#             M[i,j] = "\$\\text{$(str)}\$"
#         end
#         # M[i,j] = lines[i+skiplines][j]
#     end
# end
# M
#
# m = let m = findfirst(str->isempty(str), M[:,1])
#     m == 0 ? size(M, 1)+1 : m
# end
# n = let n = findfirst(str->isempty(str), M[2,:])
#     n == 0 ? size(M, 2)+1 : n
# end
# M[1:m-1,1:n-1]

function csv_to_tree(csv_file::AbstractString; delim=';', skiplines=2, convert_for_latex=true)
    lines = split.(readlines(csv_file), delim)

    M = fill("", length(lines)-skiplines, length(lines[1]))
    for i in 1:length(lines)-skiplines
        for j in eachindex(lines[i+skiplines])
            if convert_for_latex
                str = replace(replace(replace(replace(lines[i+skiplines][j], "^7", "^\\triangle"), r"\^$", ""), "7", "^7"), '%', "\\emptyset")
                if isempty(str)
                    continue
                elseif ismatch(r"\(.+, ?.+\)", str) # is tuple category
                    chords = split(str[2:end-1], ',')
                    (scale_deg1, key1), (scale_deg2, key2) = split.(chords, '_')
                    M[i,j] = "\$($(scale_deg1)_{$(key1)},$(scale_deg2)_{$(key2)})\$"
                elseif '_' in str
                    scale_deg, key = split(str, '_') # is single category
                    M[i,j] = "\$$(scale_deg)_{$(key)}\$"
                else # is terminal
                    M[i,j] = "\$$(str)\$"
                end
            else
                M[i,j] = lines[i+skiplines][j]
            end
        end
    end

    m = let m = findfirst(str->isempty(str), M[:,1])
        m == 0 ? size(M, 1)+1 : m
    end
    n = let n = findfirst(str->isempty(str), M[2,:])
        n == 0 ? size(M, 2)+1 : n
    end

    matrix_to_tree(M[1:m-1,1:n-1])
end

function qtree_string(tree; style="plain") # style in plain, doubled, aligned
    if style == "aligned" && isempty(tree.children)
        str = " {$(tree.data)}"
    else
        str = " [.{$(tree.data)}"
        for child in tree.children
            str *= qtree_string(child, style=style)
        end
        if style == "doubled" && isempty(tree.children)
            str *= " {$(tree.data)}"
        end
        str *= " ] "
    end
    str
end

function depth(tree)
    if isempty(tree.children)
        1
    else
        1 + maximum(depth(c) for c in tree.children)
    end
end

function save_qtree(tree, name; style="plain", format="pdf")
    d = depth(tree) - 1 + (style == "doubled" ? 1 : 0 )
    latex_string = """
    \\documentclass[11pt,a0paper]{article}
    \\usepackage{tikz-qtree}
    \\usepackage{tikz}
    \\usepackage[landscape]{geometry}
    \\begin{document}
    \\pagestyle{empty}
    \\begin{tikzpicture}[level distance=30pt]
    \\tikzset{frontier/.style={distance from root=$d*30pt}}
        \\Tree $(qtree_string(tree, style=style))
    \\end{tikzpicture}
    \\end{document}
    """

    open("$(name)_.tex", "w") do tex_file
        print(tex_file, latex_string)
    end

    run(`pdflatex $(name)_.tex`)
    run(`pdfcrop $(name)_.pdf $name.pdf`) # pdflatex could be included in the crop
    run(`rm $(name)_.aux`)
    run(`rm $(name)_.log`)
    run(`rm $(name)_.tex`)
    run(`rm $(name)_.pdf`)
    if format == "png"
        # using imagemagick
        run(`convert -density 300 $name.pdf $name.png`)
        run(`rm $(name).pdf`)
    end
end
