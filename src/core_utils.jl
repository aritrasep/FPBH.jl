findn(v) = findall(!iszero, vec(v))

function sortrows(A::AbstractMatrix; rev::Bool=false)
    p = sortperm(collect(eachrow(A)); by=row -> Tuple(row), rev=rev)
    return A[p, :]
end

float(x) = Float64(x)
