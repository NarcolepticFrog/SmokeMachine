using SmokeSignals

const BASE_DIR = "$(ENV["APPDATA"])\\.minecraft\\saves\\Smoke Signals\\datapacks\\NarcolepticFrogSmokeMachine\\data\\nf\\functions"

function save_function(name, cmds)
    open(joinpath(BASE_DIR, "$(name).mcfunction"), "w") do fh
        println(fh, cmds)
    end
end

function cmd_helix(order, repetitions)
    coords = [(2,2), (1,2), (1,3), (1,4), (2,4), (2,5), (3,5), (4,5), (4,4),
              (5,4), (5,3), (5,2), (4,2), (4,1), (3,1), (2,1)]
    skip = round(Int, length(coords)/order)
    ixs = collect(1:skip:length(coords))
    function slice_fn(t)
        slice = zeros(Bool, 5, 5)
        for ix in ixs
            wrapped_ix = (ix + t - 1) % length(coords) + 1
            slice[coords[wrapped_ix]...] = true
        end
        slice
    end
    cmd_program_from_slices(slice_fn, repetitions*length(coords))
end

function cmd_zigzag(n)
    cycle = vcat(1:5, 4:-1:1)
    function slice_fn(t)
        slice = zeros(Bool, 5, 5)
        x = cycle[(t-1)%length(cycle)+1]
        slice[x,:] .= true
        slice
    end
    cmd_program_from_slices(slice_fn, n*length(cycle))
end

for order in 1:3
    save_function("helix_$(order)", cmd_helix(order, 4))
end

save_function("zigzag", cmd_zigzag(5))

for fname in ["ball", "zombie", "letters"]
    slice_fn, num_slices = slice_fn_from_file(joinpath("slice_files", "$(fname).txt"))
    save_function(fname, cmd_program_from_slices(slice_fn, num_slices))
end
