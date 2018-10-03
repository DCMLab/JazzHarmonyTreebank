using DataFrames
using CSV
using Base.Iterators: drop

const chord_form_dict = Dict(
    ":maj7" => "^7",
    "7" => "7",
    ":min7" => "m7",
    "h7" => "%7",
    "7#9" => "7",
    "7b9" => "7",
    ":maj7#5" => "^7",
    "" => "^",
    "6" => "6",
    "9" => "7",
    ":min6" => "m6",
    "o7" => "o7",
    "+" => "+",
    "7#5" => "7",
    ":maj7#11" => "^7",
    "69" => "6",
    ":min7b5" => "%7",
    "9sus" => "sus",
    "7b9#5" => "7",
    "7b13" => "7",
    "7alt" => "7",
    "7sus" => "sus",
    ":min" => "m",
    "7#9b5" => "7",
    ":min9" => "m",
    "7#11" => "7",
    "13" => "7",
    "h" => "%7",
    "^9" => "^7",
    ":min:maj7" => "m^7",
    "11" => "7",
    ":min11" => "m7",
    "o" => "o7",
    "9#5" => "7",
    "7b9sus" => "sus",
    "7b5" => "7",
    "add9" => "7",
    "7b9b5" => "7",
    "^" => "^",
    "9#11" => "7",
    "maj7#11" => "^7",
    "maj7#5" => "^7",
    "6;" => "6",
    ":maj7;" => "^7",
    ":min6;" => "m6",
    "7#9#5" => "7",
    "13b9" => "7",
    ":minb6" => "m7",
    "7#11;" => "7",
    "13sus" => "sus",
    ":maj7#11;" => "^7",
    ":min69" => "m6",
    "maj7" => "^7",
    "^9#11" => "^7",
    ";" => "^",
    "7;" => "7",
    "13#11" => "7",
    "7b9#9" => "7",
    ":maj9" => "^7",
    "13#11;" => "7",
    "7#9#11" => "7",
    ":maj" => "^",
    "7susadd3" => "sus",
    ":min;" => "m",
    "7b9b13" => "7",
    "7b9#11" => "7",
    "7#9;" => "7",
    ":min:maj7;" => "m^7",
    ":min9;" => "m7",
    ":7" => "7",
    "769" => "7",
    ":7sus" => "sus",
    "dim7" => "o7",
    "sus" => "sus",
    "7b13sus" => "sus",
    "9;" => "7",
    "9#11;" => "7",
    ":maj7#9#11;" => "^7",
    "7#9#5;" => "7",
    "69;" => "6",
    ":maj7#9#11" => "^7",
    "9b5" => "7",
    "^;" => "^"
    )

const natural_tone_dict = Dict(
    "C" => 0,
    "D" => 2,
    "E" => 4,
    "F" => 5,
    "G" => 7,
    "A" => 9,
    "B" => 11
    )

function read_iReal_tunes(dir="/Users/daniel/Documents/GitHub/iRealPro/iRb_thru")
    files = readdir(dir)

    pieces_with_meter_change = [
        "conferenceofthebirds.jazz",
        "homecoming.jazz",
        "howmyheartsings.jazz",
        "imeanyou.jazz",
        "isayalittleprayerforyou.jazz",
        "joshua.jazz",
        "lookoflove.jazz",
        "midnightattheoasis.jazz",
        "tellmeabedtimestory.jazz",
        "walktall.jazz"
    ]

    pieces_with_strange_meter = [ # non-strange meters are "4/4", "3/4", and "6/4"
        "litha.jazz",             # 6/8 meter
        "looktotherainbow.jazz",  # 3/2. meter
        "takefive.jazz",          # 5/4
        "thebalance.jazz"         # 5/4
    ]

    iReal_tunes = DataFrame(
        file      = String[],
        title     = String[],
        composers = Vector{String}[],
        year      = Int[],
        form      = String[],
        meter     = String[],
        key       = String[],
        chords    = DataFrame[]
    )

    for (i, file) in enumerate(setdiff(files, [pieces_with_meter_change; pieces_with_strange_meter]))
        if occursin(r"^\.", file) continue end # skip hidden files

        lines = readlines(joinpath(dir, file))

        title     = ""
        composers = String[]
        year      = 0
        form      = ""
        meter     = ""
        keystring = ""

        bar = 1
        beat = 1.0
        chords = DataFrame(
            bar         = Int[],
            beat        = Float64[],
            duration    = Float64[],
            spelledroot = String[],
            pcroot      = Int[],
            chordform   = String[],
            slash       = Union{Nothing, String}[],
            alternative = Union{Nothing, String}[]
        )

        for line in lines
            if occursin(r"[!*]", line) # meta data line
                if occursin(r"^!!!OTL", line)
                    @assert title == ""
                    title = match(r"^!!!OTL: (.*)", line)[1]
                elseif occursin(r"^!!!COM", line)
                    push!(composers, match(r"^!!!COM\d?:?\t? ?(.*)", line)[1])
                elseif occursin(r"^!!!ODT", line)
                    @assert year == 0
                    year = parse(Int, match(r"^!!!ODT: (.*)", line)[1])
                elseif occursin(r"^\*>\[", line)
                    @assert form == ""
                    form = match(r"^\*>(.*)", line)[1]
                elseif occursin(r"^\*M", line)
                    # @assert meter == ""
                    meter = match(r"^\*M(.*)", line)[1]
                elseif occursin(r"^\*(.*):", line)
                    # @assert keystring == ""
                    keystring = match(r"^\*(.*):", line)[1]
                end
            elseif occursin(r"^=", line) # new bar
                bar += 1
                beat = 1.0
            elseif occursin(r"^\dr", line) # rest line
                duration = 4/parse(Int, match(r"^(\d)r", line)[1])
                beat += duration
            elseif occursin(r"^\d", line) # note line
                @assert occursin(r"(\d+)(\.*)([A-G])([-#]?)([^/]*)([A-G][-#]?)?(\(.*\))?", line)
                m = match(r"(\d+)(\.*)([A-G])([-#]?)([^/()]*)([A-G][-#]?)?(\(.*\))?", line)
                duration, punktuation, chordroot, accidential, chordform, slash, alternative =
                    4/parse(Int, m[1]), m[2], m[3], replace(m[4], "-" => "b"), m[5], m[6], m[7]
                for p in punktuation
                    duration += duration / 2
                end
                pcroot = natural_tone_dict[String(chordroot)] +
                    (occursin("#", accidential) ? length(accidential) : -length(accidential))
                spelledroot = chordroot*accidential
                push!(chords,
                    (bar, beat, duration, spelledroot, pcroot, chord_form_dict[chordform], slash, alternative)
                )

                beat += duration
            end
        end
        push!(iReal_tunes, (file, title, composers, year, form, meter, keystring, chords))
    end
    iReal_tunes
end

without(xs, ys...) = filter(x -> !(x in ys), xs)
without_columns(df, cols...) = df[ without(names(df), cols...) ]

count_dict(iter) = foldl(iter, init=Dict{eltype(iter),Int}()) do d, x
    haskey(d,x) ? d[x]+=1 : d[x]=1
    d
end

function printabbed(io, xs)
    print(io, first(xs))
    foreach(drop(xs, 1)) do x
        print(io, '\t', x)
    end
    println(io)
end

############################
###      DANGER ZONE     ###
### DO NOT RUN THIS CODE ###
############################

# drop last song "Bud Powell" since it is too long (371 chords)
# tunes = read_iReal_tunes()[1:end-1,:]
# tunes.length = tunes.chords .|> df -> size(df, 1)
# sort!(tunes, :length)
# 
# metadata = let df = copy(tunes)
#     composers = map(df.composers) do cs
#         if length(cs) == 1
#             first(cs)
#         else
#             first(cs) * mapreduce(c->"; $c", *, drop(cs, 1))
#         end
#     end
#     delete!(df, :composers)
#     df.composers = composers
#     df[[:title,:composers,:year,:meter,:key,:length]]
# end
#
# CSV.write("LausanneJazzTreebank/metadata.tsv", without_columns(metadata, :chords), delim='\t')
#
# open("LausanneJazzTreebank/data.tsv", "w") do io
#     foreach(eachrow(tunes)) do row
#         cs = row.chords
#         println(io, "NEWTUNE")
#         print(io, "title:\t");    println(io, row.title)
#         print(io, "measures:\t"); printabbed(io, cs.bar)
#         print(io, "beats:\t");    printabbed(io, cs.beat)
#         print(io, "chords:\t");   printabbed(io, map(*, cs.spelledroot, cs.chordform))
#         println(io, "keys:")
#         println(io, "applied:")
#         println(io, "tree:")
#         println(io, "approved:")
#         println(io, "comments:")
#     end
# end
