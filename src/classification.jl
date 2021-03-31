
"""
Struct representing a CPC classification symbol which holds an internal `id`, the `level` 
and corresponding `label`, the `code`, and the `title` of the symbol.
"""
struct SymbolCPC
    id::Int
    level::Int8
    label::Symbol
    code::String
    title::String
end

Base.show(io::IO, s::SymbolCPC) = print(io, "$(String(s.label)): $(s.code) | $(first(s.title, 50))..." )

# function Base.show(io::IO, ::MIME"text/plain", v::Vector{SymbolCPC})
#     println(io, "$(length(v))-element Vector of SymbolCPC")
#     for s in v
#         println(io, "$(String(s.label)): $(s.code) | $(first(s.title, 30))...")
#     end
# end

id(symbol::SymbolCPC) = symbol.id
level(symbol::SymbolCPC) = symbol.level
label(symbol::SymbolCPC) = symbol.label
code(symbol::SymbolCPC) = symbol.code
title(symbol::SymbolCPC) = symbol.title

abstract type AbstractClassification end

"""
Struct to represent the CPC patent classification system.
"""
struct ClassificationCPC <: AbstractClassification
    g::SimpleDiGraph{Int32}
    symbols::Vector{SymbolCPC}
    lookup::Dict{String, Int}
    version::String
end

Base.getindex(cpc::AbstractClassification, symbol::String) = cpc.symbols[cpc.lookup[symbol]]
Base.show(io::IO, c::ClassificationCPC) = print(io, "CPC Classification, version: $(c.version[1:4] * "." * c.version[5:6])")

abstract type LevelCPC end

struct SubgroupCPC <: LevelCPC end
struct MaingroupCPC <: LevelCPC end
struct SubclassCPC <: LevelCPC end
struct ClassCPC <: LevelCPC end
struct SectionCPC <: LevelCPC end

"""
    symbols(classification)
Obtain an array with `SymbolsCPC` contained in patent classification object `classification`. 
A struct subtyping `LevelCPC` (e.g. `SubgroupCPC`) can be passed as a second argument to only obtain symbols of that kind.
""" 
symbols(classification::AbstractClassification) = classification.symbols
symbols(classification::AbstractClassification, ::SubgroupCPC) = filter(c -> level(c) == 5, classification.symbols)
symbols(classification::AbstractClassification, ::MaingroupCPC) = filter(c -> level(c) == 4, classification.symbols)
symbols(classification::AbstractClassification, ::SubclassCPC) = filter(c -> level(c) == 3, classification.symbols)
symbols(classification::AbstractClassification, ::ClassCPC) = filter(c -> level(c) == 2, classification.symbols)
symbols(classification::AbstractClassification, ::SectionCPC) = filter(c -> level(c) == 1, classification.symbols)


"""
    parents(classification, symbols)
Get the parents for each of the symbols in `symbols`. 
`symbols` can be passed as [a vector of] `SymbolCPC` or `Strings`. 
"""
function parents(classification::AbstractClassification, symbols::Vector{SymbolCPC}) 
    n = [inneighbors(classification.g, v) for v in id.(symbols)]
    return classification.symbols[vcat(n...)]
end

parents(classification::AbstractClassification, symbol::SymbolCPC) = parents(classification, [symbol])
parents(classification::AbstractClassification, symbol::String) = parents(classification, classification[symbol])
parents(classification::AbstractClassification, symbols::Vector{String}) = parents(classification, [classification[s] for s in symbols])

"""
    children(classification, symbols)
Get the children for each of the symbols in `symbols`.
`symbols` can be passed as [a vector of] `SymbolCPC` or `Strings`. 
"""
function children(classification::AbstractClassification, symbols::Vector{SymbolCPC}) 
    n = [outneighbors(classification.g, v) for v in id.(symbols)]
    return classification.symbols[vcat(n...)]
end

children(classification::AbstractClassification, symbol::SymbolCPC) = children(classification, [symbol])
children(classification::AbstractClassification, symbol::String) = children(classification, classification[symbol])
children(classification::AbstractClassification, symbols::Vector{String}) = children(classification, [classification[s] for s in symbols])


struct SubClassificationCPC <: AbstractClassification
    idxs::Vector{Int}
    g::SimpleDiGraph{Int32}
    symbols::Vector{SymbolCPC}
    lookup::Dict{String, Int}
end

Base.show(io::IO, c::SubClassificationCPC) = print(io, "CPC Classification subgraph with $(nv(c.g)) $(nv(c.g) == 1 ? "node" : "nodes").")

function _subset_and_copy(classification::AbstractClassification, idx)
    g_sub, _ = induced_subgraph(classification.g, idx)
    syms_sub = Patents.symbols(classification)[idx]
    lookup_sub = Dict{String, Int}()
    for (i,s) in enumerate(syms_sub)
        lookup_sub[code(s)] = i
    end
    return SubClassificationCPC(idx, g_sub, syms_sub, lookup_sub)
end

function _neighbors_recursive(classification, symbols, nbfun::Function)
    _, visited = _bfs_multi(classification.g, id.(symbols), nbfun)
    visited_idx = findall(visited)
    return _subset_and_copy(classification, visited_idx)
end

"""
    parents_recursive(classification, symbols)
Traverse the classification tree given by `classification` starting at `symbols` until a source node is 
reached and return the visited symbols as a `SubClassificationCPC`.
"""
parents_recursive(classification::AbstractClassification, symbols::Vector{SymbolCPC}) = 
    _neighbors_recursive(classification, symbols, inneighbors)

parents_recursive(classification::AbstractClassification, symbol::SymbolCPC) = parents_recursive(classification, [symbol])
parents_recursive(classification::AbstractClassification, symbol::String) = parents_recursive(classification, classification[symbol])
parents_recursive(classification::AbstractClassification, symbols::Vector{String}) = parents_recursive(classification, [classification[s] for s in symbols])

"""
    children_recursive(classification, symbols)
Traverse the classification tree given by `classification` starting at `symbols` until a sink node is 
reached and return the visited symbols as a `SubClassificationCPC`.
"""
children_recursive(classification::AbstractClassification, symbols::Vector{SymbolCPC}) = 
    _neighbors_recursive(classification, symbols, outneighbors)

children_recursive(classification::AbstractClassification, symbol::SymbolCPC) = children_recursive(classification, [symbol])
children_recursive(classification::AbstractClassification, symbol::String) = children_recursive(classification, classification[symbol])
children_recursive(classification::AbstractClassification, symbols::Vector{String}) = children_recursive(classification, [classification[s] for s in symbols])

"""
    prune(classification, toplevel=1, bottomlevel=5)
Prune the classification tree given by `classification` to only include nodes in and between `toplevel` and `bottomlevel`.
"""
function prune(classification::AbstractClassification; toplevel::Int=1, bottomlevel::Int=5)
    idx = findall(s -> level(s) >= toplevel && level(s) <= bottomlevel, symbols(classification))
    return _subset_and_copy(classification, idx)
end

function common(symbols::Vector{SymbolCPC}, level::LevelCPC) end
