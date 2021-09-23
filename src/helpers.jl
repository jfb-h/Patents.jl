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
        r == 0.0 ? 0.0 : v / r
    end
end

function component(g::AbstractGraph, which=1)
    cc = weakly_connected_components(g)
    idx = sortperm(length.(cc), rev=true)
    vids = reduce(vcat, cc[idx[which]])
    induced_subgraph(g, vids)
end

function top_applicants(families, k)
    apps = reduce(vcat, applicants.(families))
    c = StatsBase.countmap(apps)
    ks = collect(keys(c)); vs = collect(values(c))
    idx = sortperm(vs, rev=true)
    NamedTuple(Symbol.(first(ks[idx], k)) .=> first(vs[idx], k))
end


function maxcentralization_degree(g)
	N = nv(g)
	if is_directed(g)
		return (N-1)*(N-1)
	else
		return (N-1)*(N-2)
	end
end

function centralization(g, measure)
	c = measure(g)
	@assert measure in [degree, indegree, outdegree]
	val, ind = findmax(c)
	return sum(val .- c) / maxcentralization_degree(g)
end

using MainPaths

function component(mp::MainPaths.MainPathResult, which=1)
    g, cs = Patents.component(mp.mainpath, which)
    vs = mp.vertices[cs]
    s = Set(mp.vertices[mp.start])
    start = findall(v -> v in s, vs)
    MainPaths.MainPathResult(g, vs, start)
end

function get_stats(mp, segment, families, g)
    idxs = mp.vertices[segment.intermediates]
    fams = families[idxs]
    ef = Dates.year.(earliest_filing.(fams))
    (;
        size = length(fams),
        span = maximum(ef) - minimum(ef),
        density = (maximum(ef) - minimum(ef)) / length(fams),
        weight = MainPaths.meanweight(mp, segment, SPCEdge(:log)(g)),
        familysize = mean(f.size for f in fams),
        citedinternal = mean(outdegree(g, idxs)),
        citedexternal = mean(citedby_count.(fams)),
        citinginternal = mean(indegree(g, idxs)),
        citingexternal = mean(cites_count.(fams)),
        classdiversity = Patents.diversity(fams, subclass),
        jurdiversity = Patents.jurdiversity(fams),
        applicant_homogeneity = Patents.share_same_applicant(fams),
        topapplicant = Patents.top_applicants(fams, 2)
    )
end

function findstart(g, fams, k; period=(2000, 2015), cpc=["Y", "B", "C"], levelfun=section)
    idx = map(fams) do f
        y = Dates.year(earliest_filing(f))
        c = levelfun.(classification(f))
        (period[1] .<= y .<= period[2]) && any(s in cpc for s in c)
    end |> findall
    cit = Patents.normalize_year(outdegree, g, fams)
    ck = sort(cit[idx], rev=true)[k]
    intersect(idx, findall(cit .>= ck))
end

