using DataFrames, CSV, JSON, TikzQTrees, DigitalMusicology

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
    tree     :: Union{SimpleTree, Missing}
    approved :: Union{String, Missing}
    comments :: Union{String, Missing}
end

function IRealTree(tune::Vector)
    title    = first(tune[1])
    measures = map(m->parse(Int, m), tune[2])
    beats    = map(m->parse(Float64, m), tune[3])
    chords   = tune[4]

    helper(x) = isempty(x) ? missing : first(x)
    foo, fooo, treestr, approved, comments = map(helper, tune[5:end])

    tree = if ismissing(treestr)
        missing
    else
        # TikzQTree(map(TikzQTrees.convert_jazz_notation, simpletree(treestr)))
        simpletree(treestr)
    end

    IRealTree(title, measures, beats, chords, tree, approved, comments)
end

function read_iRealTunes(path=joinpath(@__DIR__, "data.csv"))
    tunes = readlines(path) |>
        lines -> splititer(line -> line[1:7]=="NEWTUNE", lines) .|>
        tune  -> map(split_and_strip_empty, tune)

    map(IRealTree, tunes)
end

##################
### JazzChords ###
##################

@everywhere module Chords

using DigitalMusicology

import Base: show, ==, hash
import DigitalMusicology: root

export Chord, form

struct Chord
    root   :: SpelledPC
    form   :: String
end

root(c::Chord) = c.root
form(c::Chord) = c.form
show(io::IO, c::Chord) = print(io, c.root, c.form)

==(c::Chord, d::Chord) = c.root == d.root && c.form == d.form
hash(c::Chord, h::UInt) = hash(hash("Chord", hash(c.root, hash(c.form))), h)

function Chord(str::AbstractString)
    m = match(r"(?P<root>[A-G][b#]*)(?P<form>.*)", str)
    Chord(SpelledPC(m[:root]), string(m[:form]))
end

using Test
c = Chord("Dbm7")
@test root(c) == pc"Db"
@test form(c) == "m7"

end # module

using .Chords

major_keys = [SpelledKey(pc"C" + k * ic"5", Major) for k in -6:5]
minor_keys = [SpelledKey(pc"C" + k * ic"5", Minor) for k in -3:8]
all_keys   = [major_keys; minor_keys]

termination_dict = Dict(
    "major" => Dict(
        "I"   => ["^", "^7", "6"],
        "II"  => ["m", "m7"],
        "III" => ["m", "m7"],
        "IV"  => ["^", "^7", "6"],
        "V"   => ["^", "7", "+", "sus"],
        "VI"  => ["m", "m7"],
        "VII" => ["o7", "%7"]
    ),
    "minor" => Dict(
        "I"   => ["m", "m7", "m^7", "m6"],
        "II"  => ["%7"],
        "III" => ["^", "^7", "6"],
        "IV"  => ["m", "m7"],
        "V"   => ["m", "m7", "^", "7", "+", "sus"],
        "VI"  => ["^", "^7", "6"],
        "VII" => ["^", "7", "+", "sus"]
    )
)