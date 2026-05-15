include("utils.jl")

using LinearAlgebra
using .Utils

mutable struct TT{T}
    order::Int
    row_dims::Vector{Int}
    col_dims::Vector{Int}
    ranks::Vector{Int}
    cores::Vector{Array{T,4}}

    function TT(x::Vector{Array{Float64,4}};
                progress::Bool=false,
                string::String=nothing)
        if all(ndims.(x) .== 4)
            if all(size(x[i])[4] .== size.(x[i+1])[0] for i in 1:length(x)-1)
                order = length(x)
                row_dims = [size(x[i])[2] for i in range(order)]
                col_dims = [size(x[i])[3] for i in range(order)]
                ranks =  hcat([size(x[i])[1] for i in range(order)], [size(x[end])[4]])
                cores = x
            else
                error("Sizes of array elements do not match.")
            end
        else
            error("Array elements must be 4-dimensional arrays.")
        end
    end
end