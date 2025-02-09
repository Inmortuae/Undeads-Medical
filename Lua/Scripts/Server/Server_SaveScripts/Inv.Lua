function SaveInv(character)
    if not character or not character.Inventory then 
        print("No character or inventory found.")
        return nil 
    end

    local inventoryData = { items = {} }

    -- Recursive function to save item data, including contained items
    local function SaveItem(item, parentContainerPrefab, parentSlot)
        if not item then return end

        local itemData = {
            prefab = item.Prefab.Identifier,  -- Use the item's prefab identifier
            condition = item.Condition or 100,
            slot = parentSlot or nil,  -- Store the slot index if available
            container = parentContainerPrefab,  -- Store the prefab identifier of the parent container
            contained_items = {} -- Store nested items
        }

        -- If the item has an inventory (is a container), save its contents
        if item.OwnInventory then
            for containedItem in item.OwnInventory.AllItems do
                local containedData = SaveItem(containedItem, item.Prefab.Identifier, nil)
                table.insert(itemData.contained_items, containedData)
                print("Saved contained item: " .. tostring(containedItem.Prefab.Identifier) .. " in " .. tostring(item.Prefab.Identifier))
            end
        end

        return itemData
    end

    -- Save all items in the character's inventory
    for i = 0, character.Inventory.Capacity - 1 do
        local itemList = character.Inventory.GetItemsAt(i)
        if itemList then
            for _, item in ipairs(itemList) do
                table.insert(inventoryData.items, SaveItem(item, nil, i))
            end
        end
    end

    return inventoryData
end

function LoadInventory(target, inventoryData)
    if not target or not target.Inventory or not inventoryData then return end

    -- First pass: Spawn all top-level items
    for _, data in ipairs(inventoryData.items) do
        local params = { condition = data.condition or 100 }

        HF.SpawnItemPlusFunction(data.prefab, nil, params, target.Inventory, data.slot, target.WorldPosition)
    end

    local function GetItem(player, itemIdentifier)
        if not player or player.Inventory == nil then return nil end
        for item in player.Inventory.AllItems do
            if item.Prefab.Identifier == itemIdentifier then
                return item -- Return the item itself
            end
        end
        return nil -- Return nil if not found
    end

    Timer.Wait(function()
        -- Second pass: Load contained items into their respective containers
        for _, data in ipairs(inventoryData.items) do
            if data.prefab and data.contained_items then

                for _, containedItemData in ipairs(data.contained_items) do
                    local params = { condition = containedItemData.condition or 100 }
                    local containerItem = nil
                    local containedItem = nil
                    if containedItemData.container ~= nil then
                        containerItem = GetItem(target, containedItemData.container)
                        containedItem = containedItemData.prefab
                    end

                    HF.PutItemInsideItem(containerItem, containedItem, 1)

                end
            end
        end
    end, 50) -- Delay ensures the container is present
end