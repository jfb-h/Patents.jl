struct Family
    id::Int
    applications::Vector{Application}
end

id(family::Family) = family.id
applications(family::Family) = family.applications