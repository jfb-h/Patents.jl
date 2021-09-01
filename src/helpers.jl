using SplitApplyCombine

"""
    normalize_year(fun, fams)

Compute function `fun` for each family in `fams` and divide the result
by the average for all families with the same earliest filing date.
"""
function normalize_year(fun, fams::Vector{Family})
    year = Dates.year.(earliest_filing.(fams))
    vals = fun.(fams)
    dict = group(year, vals)
    refs = mean.(dict)
    map(zip(year, vals)) do (y, v)
        r = refs[y]
        r == 0 ? 0 : v / r
    end
end

"""
    normalize_year(fun, g, fams)

Compute function `fun` for all vertices in `g` and divide the result
by the average for all families with the same earliest filing date.
"""
function normalize_year(fun, g::AbstractGraph, fams::Vector{Family})
    year = Dates.year.(earliest_filing.(fams))
    vals = fun(g)
    dict = group(year, vals)
    refs = mean.(dict)
    map(zip(year, vals)) do (y, v)
        r = refs[y]
        r == 0 ? 0 : v / r
    end
end

function component(g::AbstractGraph, which=1)
    cc = weakly_connected_components(g)
    idx = sortperm(length.(cc), rev=true)
    vids = reduce(vcat, cc[idx[which]])
    induced_subgraph(g, vids)
end

using MainPaths

function component(mp::MainPaths.MainPathResult, which=1)
    g, cs = Patents.component(mp.mainpath, which)
    vs = mp.vertices[cs]
    s = Set(mp.vertices[mp.start])
    start = findall(v -> v in s, vs)
    MainPaths.MainPathResult(g, vs, start)
end
