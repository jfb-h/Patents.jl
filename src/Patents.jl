module Patents

using Statistics
using StatsBase
using Dictionaries
using Graphs
using Requires
import Base: ==, hash

include("applications.jl")
include("classification.jl")
include("families.jl")
include("portfolios.jl")
include("citations.jl")
include("diversity.jl")
include("helpers.jl")
include("mainpath.jl")

# function __init__()
#     @require PlotlyJS="" include("plotting.jl")
# end

export Application, ApplicationID, Title, Abstract, Claims, Classification, NPLCitation

export
lensid, id, jurisdiction, status, publicationtype, docnr, kind, nr, date,
title, titles, abstract, abstracts, claims, lang, text, 
applicants, inventors,
siblings, 
classification, code, subgroup, maingroup, subclass, class, section,
cites, cites_npl, cites_count, cites_count_npl, citedby, citedby_count

export Family, applications, jurisdictions, dates, earliest_filing, 
latest_filing, aggregate_families

export Portfolio, diversity, owner, families

export citationgraph, coclassification, normalized_citations

end
