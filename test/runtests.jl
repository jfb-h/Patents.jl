using Patents
using LightGraphs
using Test

# apps = vcat(apps...) |> unique
# fams = aggregate_families(apps)
# g = citationgraph(fams)

@testset "application" begin

end

@testset "mainpath" begin
    # start = rand(eachindex(fams), 10)
    # mp = mainpath(g, SPCEdge(:log), ForwardBackwardLocal(start))
    # mc = Patents.component(mp, 1)
    # @test all(f in fams[start] for f in fams[mc.vertices[mc.start]])
end