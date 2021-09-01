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
            # Because we're following citations here, generally only
            # all(cites_count.(fams) .< indegree(g)) will hold but normalized_citations
            # necessarily all(citedby_count(fams) .< outdegree(g)) as apparently there
            # can be references to f from other patents that not included in citedby(f).
            haskey(fdict, id(c)) || continue
            src = fdict[id(c)]
            earliest_filing(f) > earliest_filing(families[src]) || continue
            add_edge!(g, src, dst)
        end
    end

    return g
end
