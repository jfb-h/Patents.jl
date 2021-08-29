using SparseArrays, NamedArrays

function _make_incidence_matrix(applications::Vector{Application}, levelfun)
    class = reduce(vcat, classification.(applications)) |> unique 
    class = levelfun.(class) |> unique
    classdict = Dict(c => i for (i, c) in enumerate(class))
    incmat = falses(length(applications), length(class))
    for (i, a) in enumerate(applications)
        for c in classification(a)
            incmat[i, classdict[levelfun(c)]] = true
        end
    end
    return incmat, class
end

function coclassification(applications::Vector{Application}; level=maingroup)
    incmat, class = _make_incidence_matrix(applications, level)
    incmat = sparse(incmat)
    coclass = incmat' * incmat
    coclass = NamedArray(Matrix(coclass))
    setnames!(coclass, string.(class), 1)
    setnames!(coclass, string.(class), 2)
    return coclass
end
