include("utils.jl")

using LinearAlgebra
using .Utils

mutable struct TT{T<:Number}
    order::Integer
    row_dims::Vector{Integer}
    col_dims::Vector{Integer}
    ranks::Vector{Integer}
    cores::Vector{Array{T,4}}

    function TT(x::Vector{Array{T,4}})
        if all(ndims.(x) .== 4)
            if all(size(x[i])[4] .== size.(x[i + 1])[0] for i in 1:length(x) - 1)
                order = length(x)
                row_dims = [size(x[i])[2] for i in range(order)]
                col_dims = [size(x[i])[3] for i in range(order)]
                ranks =  hcat([size(x[i])[1] for i in range(order)], [size(x[end])[4]])
                cores = x

                new(order, row_dims, col_dims, ranks, cores)
            else
                error("Sizes of array elements do not match.")
            end
        else
            error("Array elements must be 4-dimensional arrays.")
        end
    end

    function TT(x::Array{T};
                threshold::AbstractFloat,
                max_rank::Unioin{Integer, Nothing},
                progress::Bool=false,
                string::String="HOSVD")
        if mod.(ndims(x)) == 2
            start_time = Utils.progress(str_text=string, percent=0.0, show=progress)

            order = div(ndims(x), 2)
            row_dims = size(x)[1:order]
            col_dims = size(x)[order + 1:end]
            ranks = ones(order+1)

            p = [order * (j - 1) + i for i = 1:order for j = 1:2]
            y = permutedims(x, reverse(p))

            for i = 1:order - 1
                m = ranks[i] * row_dims[i] * col_dims[i]
                n = prod(row_dims[i + 1:end]) * prod(col_dims[i + 1:end])
                y = reshape(y, [n, m])'

                SVD = svd(y; full=false)
                u = SVD.U
                s = SVD.S
                v = SVD.Vt

                if threshold != 0.0
                    indices = findall((s ./ s[1]) .> threshold)
                    u = u[:, indices]
                    s = s[indices]
                    v = v[indices, :]
                end
                if max_rank != Inf
                    u = u[:, 1:min(size(u, 2), max_rank)]
                    s = s[1:min(size(s, 1), max_rank)]
                    v = v[1:min(size(v, 1), max_rank), :]
                end

                ranks[i + 1] = size(u)[2]
                push!(cores, permutedims(reshape(u', [ranks[i + 1], col_dims[i], row_dims[i], ranks[i]]), [4, 3, 2, 1]))

                y = diagm(s) * v

                Utils.progress(string, 100 * (i + 1) / order, cpu_time=time() - start_time, show=progress)
            end

            push!(cores, permutedims(reshape(y', [1, col_dims[end], row_dims[end], ranks[end - 1]]), [4, 3, 2, 1]))

            TT(cores)

            Utils.progress(string, 100, cpu_time=time() - start_time, show=progress)

        else
            error("Number of dimensions must be a multiple of 2.")
        end
    end
end