
mutable struct Portfolio
    id::UUID
    owner::String
    families::Vector{Family}
    Portfolio(o::String, f::Vector{Family}) = new(UUIDs.uuid4(), o, f)
end

function Base.show(io::IO, p::Portfolio)
    print(io, "Portfolio of $(owner(p)) with $(size(p)) families" )
end

owner(p::Portfolio) = p.owner
Base.size(p::Portfolio) = length(p.families)
families(p::Portfolio) = p.families

function diversity(p::Portfolio, levelfun)
    fams = families(p)
	diversity(fams, levelfun)
end

# struct PortfolioSummary
#     size::Int
#     # Think of useful summaries
# end