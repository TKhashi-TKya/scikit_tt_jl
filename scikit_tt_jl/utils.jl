function header(title=nothing, subtitle=nothing)
    #=
    println scikit_tt_jl header.

    Parameters
    ----------
    title : string
        title or name of the procedure
    subtitle : string
        subtitle of the procedure
    =#

    println(stdout, "                                               ")
    println(stdout, ".  __    __               ___    ___ ___       ")
    println(stdout, ". /__`  /  `  |  |__/  |   |      |   |        ")
    println(stdout, "| .__/  \\__,  |  |  \\  |   |      |   |        ")
    println(stdout, "o ─────────── o ────── o ─ o ──── o ─ o ── ─  ─")

    if isnothing(title)
        println("|")
        println("o ─ " * title)
    end
    if isnothing(subtitle)
        println("    " * subtitle)
    end
    println(" ")
    println(" ")
end

function progress(str_text::String, percent::Float64, cpu_time::Float64=0.0, show::Bool=True, width::Int=47)
    #=
    Show progress in percent.

    Print strings of the form, e.g., "Running ... 10%" etc., without line breaks.

    Parameters
    ----------
    str_text : string
        string to print
    percent : float
        current progress; if percent=0, the current time is returned
    cpu_time : float
        current CPU time
    show : bool, optional
        whether to print the progress, default is True
    width : int
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
    #=
    Measure CPU time.

    Can be executed using the 'with' statement in order to measure the CPU time needed for calculations.
    =#
    
    start_time::Float64
    elapsed::Float64
end

    def __enter__(self):
        self.start_time = time.time()
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.elapsed = time.time() - self.start_time