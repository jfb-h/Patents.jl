abstract type AbstractPortfolio end

struct PortfolioApplication <: AbstractPortfolio
    owner::String
    applications::Vector{Application}
    cited::Vector{Application}
end

struct PortfolioFamily <: AbstractPortfolio
    owner::String
    applications::Vector{Family}
    cited::Vector{Application}
end

struct CitationGraph{T}
    g::SimpleDiGraph{Int32}
    nodes::T
    lookup::Dict{String, Int}
end

owner(p::AbstractPortfolio) = p.owner
applications(p::AbstractPortfolio) = p.applications
symbols(p::AbstractPortfolio) = vcat(symbols.(p.applications)...)
citations(p::AbstractPortfolio) = p.cited
Base.size(p::AbstractPortfolio) = length(p.applications)

abstract type CitationSelector end
struct CitationsForward <:CitationSelector end
struct CitationsBackward <:CitationSelector end
struct CitationsNonselfForward <:CitationSelector end
struct CitationsNonselfBackward <:CitationSelector end

function citations(g::CitationGraph{Application}, a::Application, ::CitationsForward) end
function citations(g::CitationGraph{Application}, a::Application, ::CitationsBackward) end
function citations(g::CitationGraph, a::AbstractPortfolio, ::CitationsNonselfForward) end
function citations(g::CitationGraph, a::AbstractPortfolio, ::CitationsNonselfBackward) end
# ...

# Possibilities for measuring diversity to consider:
# - own classifications
# - cited patents
# - cited patents' classification

abstract type DiversityAlgorithm end
struct ShannonWiener <: DiversityAlgorithm end
struct Herfindahl <: DiversityAlgorithm end

function diversity(p::AbstractPortfolio, classification::AbstractClassification, level::Int, ::ShannonWiener)
    pruned = prune(parents_recursive(classification, symbols(p)), toplevel=level)
    syms = filter(s -> s.level == level, symbols(pruned))
    n = length(syms)
    d = StatsBase.countmap(code.(syms))
    s = 0.0
    for v in values(d)
        p = v/n
        s += p * log(p)
    end
    return -s, d
end

diversity(p::AbstractPortfolio, classification::AbstractClassification, level::Int) = 
    diversity(p, classification, level, ShannonWiener()) 

function distance(p1, p2) end


# rand_application(cpc) = Application(
#     rand(1:10000), Date(rand(1980:2010)), "", "", rand(symbols(cpc), rand(2:10)), [Applicant(1, "BASF", "DE")], rand(Bool))

# rand_portfolio(n, cpc) = PortfolioApplication("BASF", [rand_application(cpc) for _ in 1:n], Vector{Application}())
    
