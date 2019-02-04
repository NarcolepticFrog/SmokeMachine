"Represents the position of a minecart in the machine"
struct MinecartLocation
    x::Int
    y::Int
    z::Int
    xRotation::Int
end

"""
Creates the command for summoning a chest_minecart at the given location. If
an `NBT` string is provided, it is added to the NBT data for the summoned
chest_minecart.
"""
function cmd_summon_minecart(mcl::MinecartLocation, NBT=nothing)
    command = "summon minecraft:chest_minecart $(mcl.x) $(mcl.y) $(mcl.z) {Rotation:[$(mcl.xRotation)f,0f]"
    if NBT != nothing
        command *= "," * NBT
    end
    command *= "}"
    command
end

"""
Creates the command for summoning a chest_minecart at the given location
containing the items in `il`.
"""
function cmd_summon_minecart(mcl::MinecartLocation, il::ItemList)
    if il.num_items == 0
        return cmd_summon_minecart(mcl)
    end
    nbt = make_item_nbt(il)
    cmd_summon_minecart(mcl, nbt)
end

"A dictionary mapping coordinates in the display to the memory minecart location"
const MEM_LOCATIONS = merge(
    Dict((1,z) => MinecartLocation(36, 10, z-15, 0) for z in 1:5),
    Dict((5,z) => MinecartLocation(52, 10, z-15, 0) for z in 1:5),
    Dict((2,z) => MinecartLocation(37, 5, z-15, 0) for z in 2:4),
    Dict((4,z) => MinecartLocation(51, 5, z-15, 0) for z in 2:4),
    Dict((x,1) => MinecartLocation(x+41, 10, -20, 90) for x in 2:4),
    Dict((x,5) => MinecartLocation(x+41, 10, -4, 90) for x in 2:4),
    Dict((3,2) => MinecartLocation(44, 5, -19, 90),
         (3,4) => MinecartLocation(44, 5, -5, 90)))

"A vector of the empty minecart locations"
const EMPTY_CARTS = vcat(
    [MinecartLocation(37,11,z,0) for z in -14:-10],
    [MinecartLocation(51,11,z,0) for z in -14:-10],
    [MinecartLocation(38,6,z,0) for z in -13:-11],
    [MinecartLocation(50,6,z,0) for z in -13:-11],
    [MinecartLocation(x,11,-19,90) for x in 43:45],
    [MinecartLocation(x,11,-5,90) for x in 43:45],
    [MinecartLocation(44,6,-6,90),
     MinecartLocation(44,6,-18,90)])
