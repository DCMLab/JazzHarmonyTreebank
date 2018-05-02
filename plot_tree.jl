include(joinpath(splitdir(@__FILE__)[1], "jazz_tree_tools.jl"))

csv_file = ARGS[1]
output_file = splitext(csv_file)[1]
style = length(ARGS) == 1 ? "plain" : ARGS[2]
save_qtree(csv_to_tree(csv_file), output_file, style=style, format="png")
run(`open $(output_file*".png")`)
