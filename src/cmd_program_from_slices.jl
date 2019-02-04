"""
Given a `slice_fn` function mapping from times (starting at `1`) to slices of
a 3D signal (represented as a `5x5` Matrix{Bool}`) and the number of slices,
`num_slices`, generates a command that programs the smoke machine to display
those slices.
"""
function cmd_program_from_slices(slice_fn, num_slices)
    item_lists = Dict((x,y) => ItemList() for x in 1:5, y in 1:5)
    for t in 1:num_slices
        slice = slice_fn(t)
        for x in 1:5, y in 1:5
            if slice[x,y]
                add_unstackable!(item_lists[(x,y)], t)
            end
        end
    end
    command = cmd_remove_program()
    for (coords,item_list) in item_lists
        if haskey(MEM_LOCATIONS, coords)
            command *= cmd_summon_minecart(MEM_LOCATIONS[coords],  item_list)
            command *= "\n"
        end
    end
    command
end
