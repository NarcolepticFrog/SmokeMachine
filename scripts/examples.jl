using SmokeSignals

const BASE_DIR = "$(ENV["APPDATA"])\\.minecraft\\saves\\Smoke Signals\\datapacks\\NarcolepticFrogSmokeMachine\\data\\nf\\functions"

"""
Saves the `cmds` string into a file named `name.mcfunction` in the datapack
functions folder.
"""
function save_function(name, cmds)
    open(joinpath(BASE_DIR, "$(name).mcfunction"), "w") do fh
        println(fh, cmds)
    end
end

# Main function we'll use: cmd_program_from_slices(slice_fn, num_slices)
# - slice_fn is a function that takes a time `t` and outputs which trapdoors to open
# - num_slices is just the height of the signal

# What is a slice?

#      . # # # .
#      # # . # #
#      # . . . #
#      # # . # #
#      . # # # .

function make_helix()
    coords = [(2,2), (1,2), (1,3), (1,4), (2,4), (2,5), (3,5), (4,5), (4,4),
              (5,4), (5,3), (5,2), (4,2), (4,1), (3,1), (2,1)]

    function slice_fn(t)
        slice = zeros(Bool, 5, 5)
        ix = (t - 1) % length(coords) + 1
        slice[coords[ix]...] = true
        return slice
    end

    return cmd_program_from_slices(slice_fn, 5 * length(coords))
end

save_function("helix", make_helix())
