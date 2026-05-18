module Utils

export header, progress, with_timer, truncated_svd

using LinearAlgebra

function header(title::Union{String, Nothing}=nothing, subtitle::Union{String, Nothing}=nothing)
    #=
    println scikit_tt_jl header.

    Parameters
    ----------
    title :: String
        title or name of the procedure
    subtitle :: String
        subtitle of the procedure
    =#

    println(stdout, "                                               ")
    println(stdout, ".  __    __               ___    ___ ___       ")
    println(stdout, ". /__`  /  `  |  |__/  |   |      |   |        ")
    println(stdout, "| .__/  \\__,  |  |  \\  |   |      |   |        ")
    println(stdout, "o ─────────── o ────── o ─ o ──── o ─ o ── ─  ─")

    if !isnothing(title)
        println("|")
        println("o ─ " * title)
    end
    if !isnothing(subtitle)
        println("    " * subtitle)
    end
    println(" ")
    println(" ")
end

function progress(str_text::String, percent::AbstractFloat, cpu_time::AbstractFloat=0.0, show::Bool=True, width::Integer=47)
    #=
    Show progress in percent.

    Print strings of the form, e.g., "Running ... 10%" etc., without line breaks.

    Parameters
    ----------
    str_text :: String
        string to print
    percent :: AbstractFloat
        current progress; if percent=0, the current time is returned
    cpu_time :: AbstractFloat
        current CPU time
    show :: Bool, optional
        whether to print the progress, default is True
    width :: Integer
        width of the progress bar, default is 47
    =#

    up_two = "\e[2A\r"

    if show
        if percent > 0.0
            write(stdout, up_two)
        end
        len_text = length(str_text)
        space_text = " " ^ (width - len_text)
        number_of_boxes = width - 6
        if percent == 100.0
            str_percent = "100%"
        else
            str_percent = string(round(percent, digits=1)) * "%"
        end
        len_percent = length(str_percent)
        space_percent = " " ^ (6 - len_percent)
        str_cpu = "CPU time: " * string(round(cpu_time, digits=1)) + "s"

        color_done = "\33[42m"
        color_remain = "\33[100m"
        underline = "\033[4m"
        ending = "\33[0m"


        done = Int(number_of_boxes * (floor(percent) / 100))
        str_done = " " ^ done
        str_remain = " " ^ (number_of_boxes - done)

        write(stdout, underline * str_text * space_text * ending * "\n")
        write(stdout, color_done * underline * str_done * ending)
        write(stdout, color_remain * underline * str_remain * ending)
        write(stdout, underline * space_percent * str_percent * ending * "\n")
        write(stdout, str_cpu * " ")
        flush(stdout)

        if percent == 100.0
            write(stdout, 2 ^ "\n")
        end
    end

    if percent == 0.0
        return time()
    end
end


mutable struct Timer
    start_time::AbstractFloat
    elapsed::AbstractFloat
end

function with_timer(f)
    t = Timer(time(), 0.0)

    try
        return f(t)
    finally
        t.elapsed = time() - t.start_time
    end
end


function truncated_svd(matrix::AbstractMatrix; threshold::AbstractFloat=0.0, max_rank::Union{Integer, Nothing}=nothing, rel_truncation::Bool=true)
    #=
    Compute truncated SVD.

    Parameters
    ----------
    matrix :: AbstractMatrix
        matrix to be decomposed
    threshold :: AbstractFloat, optional
        threshold for truncated SVD, default is 0
    max_rank :: Integer
        maximum rank of truncated SVD
    rel_truncation :: Bool
        truncate singular values relative to largest singular value. If False,
        parameter threshold is used as absolute truncation threshold.
        Only applies if threshold is non-zero.

    Returns
    -------
    u :: AbstractMatrix
        matrix of left singular vectors
    s :: AbstractMatrix
        vector of singular values
    v :: AbstractMatrix
        matrix of right singular vectors
    =#

    SVD = svd(matrix; full=false)
    u = SVD.U
    s = SVD.S
    v = SVD.Vt

    # rank reduction
    if threshold != 0.0
        if rel_truncation
            indices = findall((s ./ s[1]) .> threshold)
        else
            indices = findall(s .> threshold)
        end
        u = u[:, indices]
        s = s[indices]
        v = v[indices, :]
    end
    if !isnothing(max_rank)
        u = u[:, 1:min(size(u, 2), max_rank)]
        s = s[1:min(size(s, 1), max_rank)]
        v = v[1:min(size(v, 1), max_rank), :]
    end

    return u, s, v
end

end
