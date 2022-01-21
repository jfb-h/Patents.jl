using Dates

mutable struct NPLCitation
    id::String
    num::Int64
    text::String
    external_ids::Vector{String}
    NPLCitation() = new("", 0, "", String[])
end

mutable struct Title
    text::String
    lang::String
    Title() = new("", "")
end

mutable struct Abstract
    text::String
    lang::String
    Abstract() = new("", "")
end

mutable struct Claims
    text::Vector{String}
    lang::String
    Claims() = new(String[], "")
    Claims(t, l) = new(t, l)
end

lang(t::Title) = t.lang
text(t::Title) = t.text

lang(t::Abstract) = t.lang
text(t::Abstract) = t.text

lang(t::Claims) = t.lang
text(t::Claims) = t.text

mutable struct Classification
    symbol::String
    title::String
    Classification() = new("", "")
end

code(c::Classification) = c.symbol
subgroup(c::Classification) = code(c)
maingroup(c::Classification) = match(r"[^/]*", code(c)).match
subclass(c::Classification) = first(code(c), 4)
class(c::Classification) = first(code(c), 3)
section(c::Classification) = first(code(c), 1)

==(c1::Classification, c2::Classification) = code(c1) == code(c2)
hash(class::Classification, h::UInt) = hash(code(class), h)


mutable struct ApplicationID
    source::String
    id::String
    jurisdiction::String
    doc_number::String
    kind::String
    date::Date
    ApplicationID() = new("", "", "", "", "", Date(9999))
    ApplicationID(s, i, j, d, k ,dt) = new(s, i, j, d, k, dt)
end

source(a::ApplicationID) = a.source
id(a::ApplicationID) = a.id
jurisdiction(a::ApplicationID) = a.jurisdiction
docnr(a::ApplicationID) = a.doc_number
kind(a::ApplicationID) = a.kind
date(a::ApplicationID) = a.date

==(a1::ApplicationID, a2::ApplicationID) = id(a1) == id(a2)
hash(app::ApplicationID, h::UInt) = hash(id(app), h)

mutable struct Application
    id::ApplicationID
    status::String
    publication_type::String
    inventors::Vector{String}
    applicants::Vector{String}
    title::Vector{Title}
    abstract::Vector{Abstract}
    claims::Vector{Claims}
    cpc::Vector{Classification}
    siblings_simple::Vector{ApplicationID}
    cites_patents::Vector{ApplicationID}
    cites_npl::Vector{NPLCitation}
    cited_by::Vector{ApplicationID}
    family_size::Int
    cites_patents_count::Int
    cites_npl_count::Int
    cited_by_count::Int
    Application() = new(ApplicationID(), "", "", String[], String[], 
                        Title[], Abstract[], Claims[],
                        Classification[], ApplicationID[], ApplicationID[], 
                        NPLCitation[], ApplicationID[], 0, 0, 0, 0)
    
    Application(id, stat, typ, inv, app, tit, abs, claim, cpc, fam, cit, npl, 
                citby, fsize, citcount, citcountnpl, citbycount) = begin
        
        new(id, stat, typ, inv, app, tit, abs, claim, cpc, fam, cit, npl, 
            citby, fsize, citcount, citcountnpl, citbycount
        )
    end
end

id(a::Application) = id(a.id)
jurisdiction(a::Application) = jurisdiction(a.id)
docnr(a::Application) = docnr(a.id)
kind(a::Application) = kind(a.id)
nr(a::Application) = jurisdiction(a) * docnr(a) * kind(a)
date(a::Application) = date(a.id)
status(a::Application) = a.status
publicationtype(a::Application) = a.publication_type

title(a::Application) = length(a.title) == 0 ? nothing : first(a.title).text

function title(a::Application, lang::String)
	i = findfirst(t -> t.lang == lang, a.title)
	return isnothing(i) ? nothing : a.title[i].text
end

abstract(a::Application) = length(a.abstract) == 0 ? nothing : first(a.abstract).text

function abstract(a::Application, lang::String)
	i = findfirst(t -> t.lang == lang, a.abstract)
	return isnothing(i) ? nothing : a.abstract[i].text
end

claims(a::Application) = a.claims

inventors(a::Application) = a.inventors
applicants(a::Application) = a.applicants

siblings(a::Application) = a.siblings_simple
familysize(a::Application) = a.family_size

classification(a::Application) = a.cpc

cites(a::Application) = a.cites_patents
cites_npl(a::Application) = a.cites_npl
cites_count(a::Application) = a.cites_patents_count
cites_count_npl(a::Application) = a.cites_npl_count

citedby(a::Application) = a.cited_by
citedby_count(a::Application) = a.cited_by_count

==(a1::Application, a2::Application) = id(a1) == id(a2)
hash(app::Application, h::UInt) = hash(id(app), h)

function Base.show(io::IO, a::ApplicationID) 
    print(io, "$(id(a)) | $(date(a)) | $(jurisdiction(a) * docnr(a) * kind(a))" )
end

function Base.show(io::IO, a::Application) 
    print(io, "$(id(a)) | $(date(a)) | $(jurisdiction(a) * docnr(a) * kind(a))" )
end

Base.show(io::IO, t::Title) = print(io, "$(text(t))" )
Base.show(io::IO, a::Abstract) = print(io, "$(text(a))" )
