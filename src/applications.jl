struct Application
    id::Int
    filingdate::Date
    title::String
    abstract::String
    symbols::Vector{SymbolCPC}
    applicants::Vector{Applicant}
    granted::Bool
end

Base.show(io::IO, a::Application) = print(io, "Application $(a.id) | Title: $(first(a.title, 50))" )

id(app::Application) = app.id
title(app::Application) = app.title
abstract(app::Application) = app.abstract
symbols(app::Application) = app.symbols
applicants(app::Application) = app.applicants
granted(app::Application) = app.granted

