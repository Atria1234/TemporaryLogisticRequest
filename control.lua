require('init')

local function get_temporary_request_logistic_section(player, logistic_point, or_create)
    local section_name = TemporaryLogisticRequest.get_logistic_section_name(player)
    for _, section in ipairs(logistic_point.sections) do
        if section.group == section_name then
            return section
        end
    end

    if or_create then
        return logistic_point.add_section(section_name)
    end

    return nil
end

local function modify_requests(player, requested_items)
    player.play_sound({path='utility/inventory_click'})

    local character = player.character
    local player_inventory = character.get_main_inventory()

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if logistic_point then
        local section = get_temporary_request_logistic_section(player, logistic_point, true)

        for i, request in ipairs(section.filters) do
            if request.value then
                local requested_name = request.value.name
                local requested_count = requested_items[requested_name]
                if requested_count then
                    request.min = requested_count + math.max(player_inventory.get_item_count(requested_name), request.min)

                    section.set_slot(i, request)

                    requested_items[requested_name] = nil
                end
            end
        end

        -- create new requests
        local i = 1
        for requested_name, requested_count in pairs(requested_items) do
            while section.get_slot(i).value do
                i = i + 1
            end
            section.set_slot(i, {
                value = requested_name,
                min = requested_count + player_inventory.get_item_count(requested_name)
            })
        end
    end
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
        if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
            if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
                local recipe = player.character.force.recipes[event.selected_prototype.name]
                local requests = get_recipe_requests(use_result and recipe.products or recipe.ingredients, multiplier)
                if table_size(requests) == 1 then
                    create_item_flying_text(player, next(requests))
                else
                    create_recipe_flying_text(player, use_result, multiplier)
                end

                modify_requests(player, requests)
            elseif event.selected_prototype and event.selected_prototype.base_type == "item" then
                if use_result then
                    create_item_flying_text(player, event.selected_prototype.name, multiplier)

                    modify_requests(player, {
                        [event.selected_prototype.name] = multiplier
                    })
                end
            elseif event.selected_prototype and event.selected_prototype.base_type == "entity" then
                local entity_name = event.selected_prototype.name
                if event.selected_prototype.name == 'entity-ghost' then
                    local ghost_entity = player.surface.find_entity(event.selected_prototype.name, event.cursor_position)
                    if ghost_entity then
                        entity_name = ghost_entity.ghost_name
                    end
                end

                if use_result then
                    local items_to_place_this = prototypes.entity[entity_name].items_to_place_this
                    if items_to_place_this and table_size(items_to_place_this) == 1 then
                        create_item_flying_text(player, items_to_place_this[1].name, multiplier)

                        modify_requests(player, {
                            [items_to_place_this[1].name] = multiplier
                        })
                    end
                end
            end
        end
    end

    return handler
end

local function store_player_index(event)
    storage.player_inventory_changed[event.player_index] = true
end

local function cleanup_fulfilled_requests()
    for player_index, _ in pairs(storage.player_inventory_changed) do
        local player = game.players[player_index]
        if player and player.valid and player.character and player.character.valid then
            local logistic_point = player.character.get_logistic_point(defines.logistic_member_index.character_requester)

            if logistic_point then
                local section = get_temporary_request_logistic_section(player, logistic_point, false)
                if section then
                    for i, request in ipairs(section.filters) do
                        if request.value then
                            -- TODO check quality
                            local item_count = player.get_item_count(request.value.name)
                            if request.min <= item_count then
                                section.clear_slot(i)
                            end
                        end
                    end

                    if section.filters_count == 0 then
                        logistic_point.remove_section(section.index)
                    end
                end
            end
        end
    end
    storage.player_inventory_changed = {}
end

local function init_globals()
    if storage.player_inventory_changed == nil then
        storage.player_inventory_changed = {}
    end
end

local function cleanup_player_globals(event)
    storage.player_inventory_changed[event.player_index] = nil
end

script.on_event(TemporaryLogisticRequest.hotkey_names.request_1_result, create_event_handler(true, 1))
script.on_event(TemporaryLogisticRequest.hotkey_names.request_5_results, create_event_handler(true, 5))
script.on_event(TemporaryLogisticRequest.hotkey_names.request_1_ingredients, create_event_handler(false, 1))
script.on_event(TemporaryLogisticRequest.hotkey_names.request_5_ingredients, create_event_handler(false, 5))

script.on_event(defines.events.on_player_main_inventory_changed, store_player_index)
script.on_nth_tick(settings.global[TemporaryLogisticRequest.setting_names.fulfilled_request_check_rate].value, cleanup_fulfilled_requests)

script.on_init(init_globals)
script.on_configuration_changed(init_globals)
script.on_event(defines.events.on_player_removed, cleanup_player_globals)