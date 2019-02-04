using DataStructures

################
### ItemList ###
################

@enum MCItemType mc_stackable mc_unstackable

"""
Represents a sequence of stackable and non-stackable items. The most convenient
interface is to construct an empty item list with `ItemList()` and then to set
the positions of unstackable items using `add_unstackable!`.
"""
mutable struct ItemList
    unstackable_positions::SortedSet{Int}
    num_items::Int
end

"Creates an empty item list."
ItemList() = ItemList(SortedSet{Int}(), 0)

"""
Adds an unstackable item to the `ItemList` at the given position. If this item
is beyond
"""
function add_unstackable!(il::ItemList, pos)
    push!(il.unstackable_positions, pos)
    if pos > il.num_items
        il.num_items = pos
    end
end

"Number of inventory slots used by the item list."
function num_stacks(il::ItemList)
    if il.num_items <= 0
        return 0
    end
    stacks = 0
    last_pos = 0
    for pos in il.unstackable_positions
        stacks += div((pos - last_pos - 1) + 63, 64) + 1
        last_pos = pos
    end
    stacks += div((il.num_items - last_pos - 1) + 63, 64)
    stacks
end

######################
### Stack Iterator ###
######################

import Base: iterate, eltype, length

"An iterator for enumerating the stacks of an `ItemList`."
struct StackIterator
    il::ItemList
end

function Base.iterate(si::StackIterator, state = 1)
    if state > si.il.num_items
        return nothing
    elseif state in si.il.unstackable_positions
        return ((mc_unstackable,1), state+1)
    else
        next_stackable = searchsortedafter(si.il.unstackable_positions, state)
        if next_stackable == pastendsemitoken(si.il.unstackable_positions)
            last_stackable = si.il.num_items
        else
            last_stackable = deref((si.il.unstackable_positions,next_stackable))-1
        end
        stack_size = min(64, last_stackable - state + 1)
        return ((mc_stackable, stack_size), state+stack_size)
    end
end

eltype(si::StackIterator) = Tuple{MCItemType, Int}

length(si::StackIterator) = num_stacks(si.il)

#####################
### make_item_nbt ###
#####################

const STACKABLE_ITEMS = ["minecraft:"*item for item in [
        "white_wool", "orange_wool", "magenta_wool", "light_blue_wool",
        "yellow_wool", "lime_wool", "pink_wool", "gray_wool", "light_gray_wool",
        "white_stained_glass", "orange_stained_glass", "magenta_stained_glass",
        "light_blue_stained_glass", "yellow_stained_glass",
        "lime_stained_glass", "gray_stained_glass", "light_gray_stained_glass",
        "pink_stained_glass"]]

"""
Converts an `ItemList` into the NBT item data needed to encode that item list
in a minecart chest. It uses unique stackable blocks for each run of stackable
items so that the sequence is preserved when the items are passed through a
hopper.
"""
function make_item_nbt(il::ItemList)
    nbt = "Items:["
    slot = 0
    st = 1
    last_type = mc_stackable
    for (item_type, stack_size) in StackIterator(il)
        if item_type == mc_stackable
            if last_type == mc_unstackable
                st += 1
            end
            nbt *= "{Slot:$(slot),id:\"$(STACKABLE_ITEMS[st])\",Count:$(stack_size)b},"
        elseif item_type == mc_unstackable
            nbt *= "{Slot:$(slot),id:\"minecraft:stone_shovel\",Count:1b},"
        end
        last_type = item_type
        slot += 1
    end
    nbt = nbt[1:end-1]
    nbt *= "]"
    nbt
end
