using DataFrames, CSV, JSON, TikzQTrees

function simpletree(qtree_string::AbstractString)
    function qtree2json(qtree_string::AbstractString)
        app  = joinpath(@__DIR__, "qtree2json")
        path, io = mktemp(); close(io)
        run(pipeline(`$app $qtree_string`, stdout=path))
        json = JSON.parse(read(path, String))
        rm(path)
        json
    end

    function simpletree_(json::AbstractDict)
        if haskey(json, "children") # inner node
            SimpleTree(json["value"], map(simpletree_, json["children"]))
        else # leaf
            SimpleTree(json["value"])
        end
    end

    json = qtree2json(qtree_string)
    @assert haskey(json, "value") "$json must have a key called \"value\""
    simpletree_(json)
end

function splititer(p, iter; keepempty=false)
    function splititer!(p, iter, out)
        foreach(iter) do x
            if p(x)
                if keepempty || !isempty(last(out))
                    push!(out, eltype(iter)[])
                end
            else
                push!(last(out), x)
            end
        end
    end

    out = [eltype(iter)[]]
    splititer!(p, iter, out)
    out
end

function split_and_strip_empty(str)
    splitted = split(str, ';')
    k = findlast((!) ∘ isempty, split(str, ';'))
    splitted[2:k]
end

struct IRealTree
    title    :: String
    measures :: Vector{Int}
    beats    :: Vector{Float64}
    chords   :: Vector{String}
    tree     :: Union{TikzQTree, Missing}
    approved :: Union{String, Missing}
    comments :: Union{String, Missing}
end

function IRealTree(tune::Vector)
    title = first(tune[1])
    measures = map(tune[2]) do m parse(Int, m) end
    beats = map(tune[3]) do m parse(Float64, m) end
    chords = tune[4]

    helper(x) = isempty(x) ? missing : first(x)
    foo, fooo, treestr, approved, comments = map(helper, tune[5:end])

    tree = if ismissing(treestr)
        missing
    else
        TikzQTree(map(TikzQTrees.convert_jazz_notation, simpletree(treestr)))
    end

    IRealTree(title, measures, beats, chords, tree, approved, comments)
end

function read_iRealTunes(path=joinpath(@__DIR__, "data.csv"))
    tunes = readlines(path) |>
        lines -> splititer(line -> line[1:7]=="NEWTUNE", lines) .|>
        tune  -> map(split_and_strip_empty, tune)

    map(IRealTree, tunes)
end
