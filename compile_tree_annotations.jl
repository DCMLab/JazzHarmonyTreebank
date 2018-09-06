using TikzQTrees

function compile_tree_annotations()
    dir = joinpath(@__DIR__, "iReal_trees", "final_versions")
    csv_files = joinpath.(dir, filter(file->splitext(file)[2] ==".csv", readdir(dir)))
    chords = getindex.(readlines.(csv_files), 3)
    (trees = map(read_jazz_tree, csv_files), chords = chords)
end
