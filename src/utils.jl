
function _format_code(code::String)
    y = findfirst('/', code)
    if isnothing(y) || y == 9
        return code
    elseif y < 9
        w = repeat(' ', 9 - y)
        return code[1:4] * w * code[5:end]
    end
end

function download_classification(version="202102") 
    datadir = joinpath(pkgdir(Patents), "data")
    isdir(datadir) || mkdir(datadir)
    versiondir = joinpath(datadir, "v" * version)
    isdir(versiondir) || mkdir(versiondir)
    link = "https://www.cooperativepatentclassification.org/cpc/bulk/CPCTitleList" * version * ".zip"
    isfile(joinpath(versiondir, "titles.zip")) && @warn "File exists, overwriting..."
    file = download(link)
end

# TODO: In general, it would be better to use the XML data instead of txt. This also has additional info.

function load_classification_from_zip(version="202102")
    archive = joinpath(pkgdir(Patents), "data", "v" * version, "titles.zip")
    global zipped = ZipFile.Reader(archive) # TODO this global is a hack, see https://github.com/fhs/ZipFile.jl/issues/14
    levels = [
        :SectionCPC, 
        :ClassCPC,
        :SubclassCPC,
        :MaingroupCPC,
        :SubgroupCPC
    ]
    syms = Vector{SymbolCPC}()
    sizehint!(syms, 250000)
    c = 1
    for z in zipped.files
        f = CSV.File(read(z), header=["code", "title"], delim='\t')
        close(z)
        for r in f
            l = length(r.code)
            lvl = l == 1 ? 1 : l == 3 ? 2 : l == 4 ? 3 : last(r.code, 3) == "/00" ? 4 : 5
            push!(syms, SymbolCPC(c, lvl, levels[lvl], _format_code(r.code), r.title))
            c += 1
        end
    end

    lookup = Dict{String, Int}(code.(syms) .=> 1:length(syms))
    g = SimpleDiGraph{Int32}(length(syms))
    len = [1, 3, 4, 8]

    for (i, s) in enumerate(syms)
        code_s, level_s = code(s), level(s)
        level_s == 1 && continue
        parent_code = first(code_s, len[level_s - 1])
        level_s == 5 && (parent_code = parent_code  * "/00")
        haskey(lookup, parent_code) || continue # TODO e.g. A01D2017 does not follow the pattern
        parent_idx = lookup[parent_code]
        add_edge!(g, parent_idx, i)
    end

    return ClassificationCPC(g, syms, lookup, version)
end


# function _format_file(file)
#     df = CSV.File(file, header=false, delim='\t') |> DataFrame
#     rename!(df, :Column1 => :code, :Column2 => :title)
#     df[!,1] .= format_cpc.(df[!,1])
#     return df
# end

# function reformat_files(dir_input="titles_raw", dir_output="titles_formatted")
#     section   = DataFrame(code=String[], title=String[])
#     class     = DataFrame(code=String[], title=String[])
#     subclass  = DataFrame(code=String[], title=String[])
#     subgroup  = DataFrame(code=String[], title=String[])

#     files = readdir(dir_input)
#     for f in files
#         df = joinpath(dir_input, f) |> format_file
#         append!(section,   filter(r -> length(r.code) == 1, df))
#         append!(class,     filter(r -> length(r.code) == 3, df))
#         append!(subclass,  filter(r -> length(r.code) == 4, df))
#         append!(subgroup, filter(r -> length(r.code) >= 8, df))
#     end

#     maingroup = filter(r -> r.code[end-2:end] == "/00", subgroup)
#     maingroup.code = [c[begin:end-3] for c in maingroup.code]

#     CSV.write(joinpath(dir_output, "section.csv"), section)
#     CSV.write(joinpath(dir_output, "class.csv"), class)
#     CSV.write(joinpath(dir_output, "subclass.csv"), subclass)
#     CSV.write(joinpath(dir_output, "maingroup.csv"), maingroup)
#     CSV.write(joinpath(dir_output, "subgroup.csv"), subgroup)
# end


function _bfs_multi(g::AbstractGraph{T}, source, neighborfn::Function) where T
    n = nv(g)
    visited = falses(n)
    parents = [Vector{T}() for _ in 1:n]
    cur_level = Vector{T}()
    sizehint!(cur_level, n)
    next_level = Vector{T}()
    sizehint!(next_level, n)
    @inbounds for s in source
        visited[s] = true
        push!(cur_level, s)
        parents[s] = [s]
    end
    while !isempty(cur_level)
        @inbounds for v in cur_level
            @inbounds @simd for i in neighborfn(g, v)
                if visited[i]
                    push!(parents[i], v)
                else
                    push!(next_level, i)
                    push!(parents[i], v)
                    visited[i] = true
                end
            end
        end
        empty!(cur_level)
        cur_level, next_level = next_level, cur_level
        sort!(cur_level)
    end
    return parents, visited
end
