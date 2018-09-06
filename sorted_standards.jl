using DataFrames

dir = "iReal_csv"
files = readdir(dir)

df = sort(
    DataFrame(
        tune = files,
        length = length.(split.(getindex.(readlines.(joinpath.(dir, files)), 3), ';'))
        ),
    cols = :length
    )

writetable("sorted_standards.tsv", df)
