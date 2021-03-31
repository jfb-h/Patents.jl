using Patents
using LightGraphs
using Test


@testset "Classification" begin
    cpc = Patents.load_classification_from_zip()
    #cpc.version == "202102" && @test nv(cpc.g) == 260227
    @test length(cpc.symbols) == nv(cpc.g)
    @test typeof(cpc["A"]) == SymbolCPC
    @test all(id.(symbols(cpc)) .== [cpc.lookup[code(s)] for s in symbols(cpc)])
    @test all(level.(children(cpc, "A")) .== 2)
    @test parents(cpc, "B01") == parents(cpc, cpc["B01"])
    @test all(label.(symbols(cpc, SubgroupCPC())) .== :SubgroupCPC)
    @test all(level.(children(cpc, symbols(cpc, MaingroupCPC()))) .== 5)
    @test all(level.(parents(cpc, symbols(cpc, SubclassCPC()))) .== 2)
    @test length(parents(cpc, symbols(cpc, MaingroupCPC()))) == length(symbols(cpc, MaingroupCPC()))
    @test length(unique(parents(cpc, symbols(cpc, MaingroupCPC())))) == length(symbols(cpc, SubclassCPC()))
end
