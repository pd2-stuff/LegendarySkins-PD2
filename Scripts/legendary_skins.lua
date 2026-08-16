-- Legendary Skins: safer initialization for current PAYDAY 2 builds.
-- Runs once and preserves the original tradable-update function.

local blackmarket = managers.blackmarket
if not blackmarket or not tweak_data.blackmarket then
    return
end

local weapon_skins = tweak_data.blackmarket.weapon_skins
local inventory = blackmarket._global.inventory_tradable

if not weapon_skins or not inventory then
    return
end

local function next_inventory_id()
    local highest = 0

    for key in pairs(inventory) do
        local number_key = tonumber(key)
        if number_key and number_key > highest then
            highest = number_key
        end
    end

    return highest + 1
end

local function unlock_skins_once()
    if blackmarket._legendary_skins_initialized then
        return
    end
    blackmarket._legendary_skins_initialized = true

    local next_id = next_inventory_id()

    for skin_id, skin_data in pairs(weapon_skins) do
        if not string.find(skin_id, "color", 1, true) then
            skin_data.locked = false

            if not blackmarket:have_inventory_tradable_item("weapon_skins", skin_id) then
                blackmarket:tradable_add_item(
                    tostring(next_id),
                    "weapon_skins",
                    skin_id,
                    "mint",
                    true,
                    1
                )
                next_id = next_id + 1
            end
        end
    end

    local crafted = blackmarket._global.crafted_items
    if crafted then
        for _, category in pairs({ crafted.primaries, crafted.secondaries }) do
            if category then
                for _, weapon_data in pairs(category) do
                    if weapon_data.cosmetics then
                        weapon_data.customize_locked = nil
                    end
                end
            end
        end
    end

    for _, safe in pairs(tweak_data.economy.safes or {}) do
        if not safe.market_link then
            safe.market_link = "Fake Link"
        end
    end
end

unlock_skins_once()

local original_tradable_update = BlackMarketManager.tradable_update
function BlackMarketManager:tradable_update(...)
    if original_tradable_update then
        original_tradable_update(self, ...)
    end
end
