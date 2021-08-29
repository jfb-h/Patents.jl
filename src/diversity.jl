
findbranches(mp) = findall(outdegree(mp) .> 1)

findmerges(mp) = findall(indegree(mp) .> 1)

findjunctions(mp) = intersect(findbranches(mp), findmerges(mp))


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

function merge_scope(fams, net, v)
	fam = fams[v]
	citedcpc = String[]
	cited = inneighbors(net, v)
	length(cited) == 0 && return nothing
	for c in cited
		append!(citedcpc, subgroup.(classification(fams[c])))
	end
	
	return length(unique(citedcpc))
end

function branch_scope(fams, net, v)
	fam = fams[v]
	citingcpc = String[]
	citing = outneighbors(net, v)
	length(citing) == 0 && return nothing
	for c in citing
		append!(citingcpc, subgroup.(classification(fams[c])))
	end
	
	return length(unique(citingcpc))
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
