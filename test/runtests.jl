using Patents
using PatentsLens
using Graphs
using Test

apps = PatentsLens.read("data/portfolio_carbios.jsonl")
fams = aggregate_families(apps)
g = citationgraph(fams)

@testset "application" begin
    @test apps isa Vector{Application}
    @test fams isa Vector{Family}

end

@testset "mainpath" begin
    # start = rand(eachindex(fams), 10)
    # mp = mainpath(g, SPCEdge(:log), ForwardBackwardLocal(start))
    # mc = Patents.component(mp, 1)
    # @test all(f in fams[start] for f in fams[mc.vertices[mc.start]])
end