"""
Generates the minecraft commands necessary to remove the current program from
the smoke machine. First removes items from each of the minecarts, then kills
all minecarts, and finally adds empty minecarts above each hopper.
"""
function cmd_remove_program()
    command = "execute as @e[type=minecraft:chest_minecart] run data merge entity @s {Items:[]}\n"
    command *= "kill @e[type=minecraft:chest_minecart]\n"
    for mcl in EMPTY_CARTS
        command *= cmd_summon_minecart(mcl) * "\n"
    end
    command
end

"""
Given a vector of strings, each encoding one slice, returns a `slice_fn` and
`num_slices` that can be passed into `cmd_program_from_slices` to program the
smoke machine. This function expects to find 25 `.`s or '#`s in each string,
encoding the slice in row-major order. All other characters are ignored.
```
# . . . #
. . # . .
. # . # .
. . # . .
# . . . #
```
Each `#` character indicatees that smoke should be allowed to flow.
"""
function slice_fn_from_strings(strs)
    function slice_fn(t)
        slice = zeros(Bool, 5, 5)
        x = 1
        y = 1
        for c in strs[t]
            if c == '#'
                slice[x,y] = true
            end
            if c == '.' || c == '#'
                x += 1
                if x > 5
                    x = 1
                    y += 1
                end
            end
        end
        slice
    end
    return slice_fn, length(strs)
end

"""
The same as `slice_fn_from_strings` except it loads the slice strings from a
file. Ignores any line staring with -. The given strings are reversed before
passing them into slice_fn_from_strings so that slice strings at the top of the
file correspond to the top of the 3D shape.
"""
function slice_fn_from_file(path)
    lines = filter(line -> !startswith(line, '-'), collect(eachline(path)))
    slice_strings = [join(lines[i:i+4], '\n') for i in 1:5:length(lines)]
    slice_fn_from_strings(slice_strings[end:-1:1])
end
