
# findbranches(g) = begin
# 	vs = findall(outdegree(g) .> 1)
# 	idx = map(vs) do v
# 		onb = outneighbors(g, v)
# 		any(outdegree(g, onb) .> 0) && return true
# 		return false
# 	end
# 	vs[idx]
# end

# findmerges(g) = begin
# 	vs = findall(indegree(g) .> 1)
# 	idx = map(vs) do v
# 		onb = inneighbors(g, v)
# 		any(indegree(g, onb) .> 0) && return true
# 		return false
# 	end
# 	vs[idx]
# end

# findjunctions(mp) = intersect(findbranches(mp), findmerges(mp))


function diversity(fams::Vector{Family}, levelfun)
	class = classification.(fams) |> Iterators.flatten .|> levelfun
	
	# class = classification.(fams)
	# class = map(class) do c
	# 	cs = levelfun.(c)
	# 	unique(cs)
	# end
	# class = Iterators.flatten(class) |> collect

	n = length(class)
    d = StatsBase.countmap(class)
    s = 0.0
    for v in values(d)
        p = v/n
        s += p * log(p)
    end
    -s
end

function orgdiversity(fams::Vector{Family})
	apps = reduce(vcat, applicants.(fams))
	n = length(apps)
    d = StatsBase.countmap(apps)
    s = 0.0
    for v in values(d)
        p = v/n
        s += p * log(p)
    end
    -s
end

function share_same_applicant(fams::Vector{Family})
	apps = reduce(vcat, applicants.(fams))
    d = StatsBase.countmap(apps)
    maximum(values(d)) / length(fams)
end

function jurdiversity(fams::Vector{Family})
	apps = reduce(vcat, jurisdiction.(fams))
	n = length(apps)
	d = StatsBase.countmap(apps)
	s = 0.0
	for v in values(d)
		p = v/n
		s += p * log(p)
	end
	-s
end

function organizational_branching(mp, fam, v)
    focal = fam[v]
    outnb = fam[outneighbors(mp, v)]
    res = 0.0
    for o in outnb
        for a in applicants(o)
            if a in applicants(focal)
                res += 1
                break
            end
        end
    end
    return res / length(outnb)
end

function organizational_merging(mp, fam, v)
    focal = fam[v]
    innb = fam[inneighbors(mp, v)]
    res = 0.0
    for o in innb
        for a in applicants(o)
            if a in applicants(focal)
                res += 1
                break
            end
        end
    end
    return res / length(innb)
end


function merged_diversity_intersect(fams, net, v)
	fam = fams[v]
	cpc = subgroup.(classification(fam))
	citedcpc = String[]
	cited = inneighbors(net, v)
	length(cited) == 0 && return nothing
	for c in cited
		append!(citedcpc, subgroup.(classification(fams[c])))
	end
	return length(intersect(cpc, citedcpc)) / length(union(cpc, citedcpc))
end	

function branched_diversity_intersect(fams, net, v)
	fam = fams[v]
	cpc = subgroup.(classification(fam))
	citedcpc = String[]
	citing = outneighbors(net, v)
	length(citing) == 0 && return nothing
	for c in citing
		append!(citedcpc, subgroup.(classification(fams[c])))
	end
	return length(intersect(cpc, citedcpc)) / length(union(cpc, citedcpc))
end	

function backward_diversity(fams, net, v; normalize=true)
	fam = fams[v]
	citedcpc = String[]
	cited = inneighbors(net, v)
	length(cited) == 0 && return 0.0
	for c in cited
		append!(citedcpc, section.(classification(fams[c])))
	end
	
	res = length(unique(citedcpc))
	normalize && return res / length(cited)
	return float.(res)
end

function forward_diversity(fams, net, v; normalize=true)
	fam = fams[v]
	citingcpc = String[]
	citing = outneighbors(net, v)
	length(citing) == 0 && return 0.0
	for c in citing
		append!(citingcpc, section.(classification(fams[c])))
	end
	
	res = length(unique(citingcpc))
	normalize && return res / length(citing)
	return float.(res)
end

function merge_mode(fams, net, v)
	fam = fams[v]
	citedcpc = String[]
	cited = inneighbors(net, v)
	length(cited) == 0 && return nothing
	for c in cited
		append!(citedcpc, subgroup.(classification(fams[c])))
	end
	
	freq = StatsBase.countmap(citedcpc)
	return maximum(values(freq))
end

function branch_mode(fams, net, v)
	fam = fams[v]
	citingcpc = String[]
	citing = outneighbors(net, v)
	length(citing) == 0 && return nothing
	for c in citing
		append!(citingcpc, subgroup.(classification(fams[c])))
	end
	
	freq = StatsBase.countmap(citingcpc)
	return maximum(values(freq))
end
