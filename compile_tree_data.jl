include(joinpath(splitdir(@__FILE__)[1], "jazz_tree_tools.jl"))

tree_files = filter(readdir("iReal_trees")) do f
    splitext(f)[2] == ".csv"
end

names = getindex.(splitext.(tree_files), 1)
trees = csv_to_tree.(joinpath.("iReal_trees", tree_files), convert_for_latex=false)
terminals = leaf_data.(trees)

open("compiled_tree_data.txt", "w") do f
    for i in 1:length(tree_files)
        println(f, names[i])
        println(f, terminals[i])
        println(f, trees[i])
    end
end
