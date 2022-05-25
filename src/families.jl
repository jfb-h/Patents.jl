using UUIDs

abstract type AbstractFamily end

mutable struct Family <: AbstractFamily
    id::UUID
    size::Int
    applications::Vector{Application}
    Family() = new(UUIDs.uuid4(), 0, Application[])
    Family(id, s, apps) = new(id, s, apps)
end

id(f::Family) = f.id
applications(f::Family) = f.applications
Base.size(f::Family) = f.size

jurisdiction(f::Family) = unique(jurisdiction(a) for a in applications(f))
dates(f::Family) = [date(a) for a in applications(f)]
earliest_filing(f::Family) = minimum(dates(f))
latest_filing(f::Family) = maximum(dates(f))

titles(f::Family) = [title(a) for a in applications(f)]

function title(f::Family, lang::String)
    a = applications(f)
    i = findfirst(x -> !isnothing(title(x, lang)), a)
    return isnothing(i) ? nothing : title(a[i], lang)
end

abstracts(f::Family) = [abstract(a) for a in applications(f)]

function abstract(f::Family, lang::String)
    a = applications(f)
    i = findfirst(x -> !isnothing(abstract(x, lang)), a)
    return isnothing(i) ? nothing : abstract(a[i], lang)
end

function applicants(f::Family) 
    apps = applications(f)
    appl = reduce(vcat, applicants.(apps))
    return unique(appl)
end

function inventors(f::Family) 
    apps = applications(f)
    inv = reduce(vcat, inventors.(apps))
    return unique(inv)
end

function classification(fam::Family)
	apps = applications(fam)
	class = reduce(vcat, classification.(apps))
	return unique(class)
end

cites(f::Family) = reduce(vcat, cites(a) for a in applications(f)) |> unique
cites_count(f::Family) = length(cites(f))
cites_npl(f::Family) = reduce(vcat, cites_npl(a) for a in applications(f)) |> unique
citedby(f::Family) = reduce(vcat, citedby(a) for a in applications(f)) |> unique
citedby_count(f::Family) = length(citedby(f))

# function citedby_count(f::Family)
#     res = Set{String}()
#     count = 0
#     for a in applications(f)
#         for c in citedby(a)
#             incr = ifelse(id(c) in res, 0, 1)
#             push!(res, id(c))
#             count += incr
#         end
#     end
#     count
# end

function Base.show(io::IO, f::Family)
    print(io, "Family with $(f.size) members" )
end

function Base.show(io::IO, ::MIME"text/plain", f::Family)
    tit = title(f, "en")
    tit = isnothing(tit) ? first(titles(f)) : tit
    abs = abstract(f, "en")
    abs = isnothing(abs) ? first(abstracts(f)) : abs
    
    println(io, "----------------------")
    println(io, "Size: $(f.size)")
    println(io, "Earliest filing: $(earliest_filing(f))")
    println(io, "Latest filing: $(maximum(dates(f)))")
    println(io, "Cited by: $(citedby(f) |> length)")
    println(io, "Filed in: $(join(jurisdiction(f), ", "))")
    println(io, "Applicants: $(join(applicants(f), ", "))")
    println(io, "Subgroups: $(join(subgroup.(classification(f)), ", "))")
    println(io, "----------------------")
    println(io, "Title: $tit\n")
    println(io, "Abstract: $abs")
end

# function Base.show(io::IO, ::MIME"text/plain", f::Family) 

# end

# function Base.show(io::IO, ::MIME"text/markdown", f::Family) 
#     tit = reduce(vcat, title.(applications(f)))
#     idx_tit = findfirst(lang.(tit) .== "en")
#     tit = isnothing(idx_tit) ? text(first(tit)) : text(tit[idx_tit])
#     abs = reduce(vcat, abstract.(applications(f)))
#     idx_abs = findfirst(lang.(abs) .== "en")
#     abs = isnothing(idx_abs) ? text(first(abs)) : text(abs[idx_abs])

#     md"""
#     ##### $tit
    
#     **Size:** $(f.size)
#     **Earliest filing: $(earliest)
#     **Earliest filing:** $(earliest_filing(f))
#     **Latest filing:** $(maximum(dates(f)))
#     **Cited by:** $(citedby(f) |> length)
#     **Filed in:** $(join(jurisdiction(f), ", "))
#     **Applicants:** $(join(applicants(f), ", "))
#     ---
#     **Abstract:** $abs
#     """
# end

function aggregate_families(apps::Vector{Application})
    visited = Dict(id(a) => false for a in apps)
    idx = Dict(id(a) => i for (i, a) in enumerate(apps))
    families = Family[]
    for a in apps
        visited[id(a)] && continue
        applications = Application[]
        push!(applications, a)
        for s in siblings(a)
            haskey(idx, id(s)) || continue
            push!(applications, apps[idx[id(s)]])
            visited[id(s)] = true
        end
        push!(families, Family(UUIDs.uuid4(), familysize(a), applications))
    end
    return families
end
