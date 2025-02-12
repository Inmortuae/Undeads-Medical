function TransferInventory(character, target)
    -- Transfer inventory items while preserving genetic material locations
    if character.Inventory ~= nil and target.Inventory ~= nil then
        local geneticMaterials = {} -- Stores genetic material data (item + location)

        -- First pass: Identify genetic materials and store their locations
        for i = 0, math.min(character.Inventory.Capacity - 1, target.Inventory.Capacity - 1) do
            local list = character.Inventory.GetItemsAt(i)
            if list then
                for _, item in ipairs(list) do
                    if item ~= nil and item.Prefab.Identifier == "geneticmaterial" then
                        -- Store the genetic material's original container and slot
                        geneticMaterials[#geneticMaterials + 1] = {
                            item = item,
                            slot = i, -- Original inventory slot
                            container = item.ParentInventory -- Could be a Gene Splicer or another item
                        }
                    end
                end
            end
        end

        -- Second pass: Transfer all items (except genetic material)
        for i = 0, math.min(character.Inventory.Capacity - 1, target.Inventory.Capacity - 1) do
            local list = character.Inventory.GetItemsAt(i)
            if list then
                for _, item in ipairs(list) do
                    if item ~= nil and target and item.Prefab.Identifier ~= "geneticmaterial" then
                        item.Drop()
                        Timer.Wait(function()
                            target.Inventory.TryPutItem(item, i, true, true, nil)
                        end, 35)
                    end
                end
            end
        end

        -- Third pass: Re-add genetic material to its original location
        Timer.Wait(function()
            for _, data in ipairs(geneticMaterials) do
                if data.item ~= nil then
                    if data.container ~= nil and data.container.ParentInventory == target.Inventory then
                        -- Place the genetic material back in the exact same container (e.g., Gene Splicer)
                        data.container.TryPutItem(data.item, data.slot, true, true, nil)
                    else
                        -- Otherwise, place it back into the new human's inventory in the same slot
                        target.Inventory.TryPutItem(data.item, data.slot, true, true, nil)
                    end
                end
            end
        end, 50) -- Slight delay to ensure it happens after main transfer
    end
end