using Patents
using Documenter

DocMeta.setdocmeta!(Patents, :DocTestSetup, :(using Patents); recursive=true)

makedocs(;
    modules=[Patents],
    authors="Jakob Hoffmann",
    repo="https://github.com/jfb-h/Patents.jl/blob/{commit}{path}#{line}",
    sitename="Patents.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jfb-h.github.io/Patents.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jfb-h/Patents.jl",
)
