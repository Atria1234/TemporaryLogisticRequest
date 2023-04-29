local infinity = 4294967295
local max_request_slot = 65536
local is_this_mod_modifying_requests = false

local function get_old_requests(player_index)
    if global.old_requests[player_index] == nil then
        global.old_requests[player_index] = {}
    end

    return global.old_requests[player_index]
end

local function modify_requests(character, requested_items)
    character.player.play_sound({path='utility/inventory_click'})
    is_this_mod_modifying_requests = true

    local old_requests = get_old_requests(character.player.index)
    local player_inventory = character.get_main_inventory()

    -- modify already existing requests
    for slot = 1, character.request_slot_count do
        local request = character.get_personal_logistic_slot(slot)
        local requested_count = requested_items[request.name]
        if request.name ~= nil and requested_count ~= nil then
            if old_requests[slot] == nil then
                old_requests[slot] = {
                    min = request.min,
                    max = request.max
                }
            end

            local min = math.max(player_inventory.get_item_count(request.name), request.min)
            local increase = requested_count + min - request.min
            request.min = requested_count + min
            request.max = math.min(request.max + increase, infinity)

            character.set_personal_logistic_slot(slot, request)

            requested_items[request.name] = nil
        end
    end

    -- create new requests
    for slot = 1, max_request_slot do
        if next(requested_items) == nil then
            break
        end

        local request = character.get_personal_logistic_slot(slot)
        if request.name == nil then
            local requested_name, requested_count = next(requested_items)
            old_requests[slot] = {
                min = nil,
                max = nil
            }
            character.set_personal_logistic_slot(slot, {
                name = requested_name,
                min = requested_count + player_inventory.get_item_count(requested_name),
                max = nil
            })

            requested_items[requested_name] = nil
        end
    end
    is_this_mod_modifying_requests = false
end

local function get_recipe_requests(ingredients_or_products, multiplier)
    local items = {}
    for _, item in ipairs(ingredients_or_products) do
        if item.type == "item" then
            items[item.name] = multiplier * (item.amount or 1)
        end
    end

    return items
end

local function create_recipe_flying_text(player, use_result, count)
    player.create_local_flying_text({
        text = {
            'flying-text.TemporaryLogisticRequest__request-increased',
            {
                use_result and 'flying-text.TemporaryLogisticRequest__recipe-products' or 'flying-text.TemporaryLogisticRequest__recipe-ingredients'
            },
            count
        },
        create_at_cursor = true
    })
end

local function create_item_flying_text(player, item_name, count)
    player.create_local_flying_text({
        text = {
            'flying-text.TemporaryLogisticRequest__request-increased',
            {
                '?',
                {'item-name.'..item_name},
                {'entity-name.'..item_name},
                item_name
            },
            count
        },
        create_at_cursor = true
    })
end

local function create_event_handler(use_result, multiplier)
    local function handler(event)
        local player = game.players[event.player_index]
        if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
            if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
                local recipe = player.character.force.recipes[event.selected_prototype.name]
                local requests = get_recipe_requests(use_result and recipe.products or recipe.ingredients, multiplier)
                if table_size(requests) == 1 then
                    create_item_flying_text(player, next(requests))
                else
                    create_recipe_flying_text(player, use_result, multiplier)
                end

                modify_requests(player.character, requests)
            end
        elseif event.selected_prototype and event.selected_prototype.base_type == "item" then
            if use_result then
                create_item_flying_text(player, event.selected_prototype.name, multiplier)

                modify_requests(player.character, {
                    [event.selected_prototype.name] = multiplier
                })
            end
        elseif event.selected_prototype and event.selected_prototype.base_type == "entity" then
            if use_result then
                local items_to_place_this = game.entity_prototypes[event.selected_prototype.name].items_to_place_this
                if items_to_place_this and table_size(items_to_place_this) == 1 then
                    create_item_flying_text(player, items_to_place_this[1].name, multiplier)

                    modify_requests(player.character, {
                        [items_to_place_this[1].name] = multiplier
                    })
                end
            end
        end
    end

    return handler
end

local function reset_old_request(event)
    -- if player's requests are modified NOT by this mod
    if not is_this_mod_modifying_requests and event.entity.type == 'character' and event.entity.player then
        get_old_requests(event.entity.player.index)[event.slot_index] = nil
    end
end

local function store_player_index(event)
    global.player_inventory_changed[event.player_index] = true
end

local function cleanup_fulfilled_requests()
    for player_index, _ in pairs(global.player_inventory_changed) do
        local player = game.players[player_index]
        if player and player.valid and player.character and player.character.valid then
            local inventory = player.get_main_inventory()
            local old_requests = get_old_requests(player_index)
            for slot, old_request in pairs(old_requests) do
                local request = player.character.get_personal_logistic_slot(slot)
                if request.name and inventory.get_item_count(request.name) >= request.min then
                    if old_request.min ~= nil then
                        request.min = old_request.min
                        request.max = old_request.max
                        player.character.set_personal_logistic_slot(slot, request)
                    else
                        player.character.clear_personal_logistic_slot(slot)
                    end

                    old_requests[slot] = nil
                end
            end
        end
    end
    global.player_inventory_changed = {}
end

local function init_globals()
    if global.old_requests == nil then
        global.old_requests = {}
    end
    if global.player_inventory_changed == nil then
        global.player_inventory_changed = {}
    end
end

local function cleanup_player_globals(event)
    global.old_requests[event.player_index] = nil
    global.player_inventory_changed[event.player_index] = nil
end

script.on_event("TemporaryLogisticRequest__increase-request", create_event_handler(true, 1))
script.on_event("TemporaryLogisticRequest__increase-request-5", create_event_handler(true, 5))
script.on_event("TemporaryLogisticRequest__increase-request-recipe-ingredients", create_event_handler(false, 1))
script.on_event("TemporaryLogisticRequest__increase-request-recipe-ingredients-5", create_event_handler(false, 5))

script.on_event(defines.events.on_entity_logistic_slot_changed, reset_old_request)
script.on_event(defines.events.on_player_main_inventory_changed, store_player_index)
script.on_nth_tick(settings.global['TemporaryLogisticRequest__fulfiled-request-check-rate'].value, cleanup_fulfilled_requests)

script.on_init(init_globals)
script.on_configuration_changed(init_globals)
script.on_event(defines.events.on_player_removed, cleanup_player_globals)