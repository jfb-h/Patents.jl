module Patents

using LightGraphs
using ZipFile
using CSV
using Dates
using StatsBase

include("classification.jl")
include("applicants.jl")
include("applications.jl")
include("families.jl")
include("portfolios.jl")
include("utils.jl")

export Application
export id, title, abstract, classification, applicants

export Family

export Applicant
export name

export ClassificationCPC
export symbols

export SymbolCPC
export level, label, code
export parents, children, parents_recursive, children_recursive

export prune

export SubgroupCPC, MaingroupCPC, SubclassCPC, ClassCPC, SectionCPC


end
