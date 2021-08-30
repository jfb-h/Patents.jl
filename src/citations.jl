using LightGraphs

function _make_familydict(families::Vector{Family})
    res = Dict{String, Int}()
    for (i, f) in enumerate(families)
        for a in applications(f)
            #haskey(res, id(a)) && continue
            push!(res, id(a) => i)
        end
    end
    return res
end

"""
    citationgraph(families)

Return a `SimpleDiGraph` representing the network of citations among `families`.
An edge from node i to node j indicates that j cited i and will be included in the
output graph iff the earliest filing of j is after that of i.
"""
function citationgraph(families::Vector{Family})
    fdict = _make_familydict(families)
    haskey(fdict, "") && delete!(fdict, "")
    g = SimpleDiGraph(length(families))

    for (dst, f) in enumerate(families)
        for c in cites(f)
            haskey(fdict, id(c)) || continue
            src = fdict[id(c)]
            earliest_filing(f) > earliest_filing(families[src]) || continue
            add_edge!(g, src, dst)
        end
    end

    return g
end

function _earliest_filing_reference_citationcount(families)
    ref = Dict{Int, Vector{Int}}()
    for f in families
        y = Dates.year(earliest_filing(f))
        if haskey(ref, y)
            push!(ref[y], citedby_count(f))
        else
            push!(ref, y => [citedby_count(f)])
        end
    end

    out = Dict{Int, Float64}(keys(ref) .=> 0.0)
    for x in ref
        y = x[1]; cit = x[2]
        out[y] = mean(cit)
    end

    out
end

"""
    normalized_citations(families)

Compute the number of citations for all families in `families`, normalized relative to the
mean citation count of all families in the collection with the same earliest filing year.
"""
function normalized_citations(families::Vector{Family})
    ref = _earliest_filing_reference_citationcount(families)
    map(families) do f
        count = citedby_count(f)
        refcount = ref[Dates.year(earliest_filing(f))]
        refcount == 0 ? 0.0 : count/refcount
    end
end
