require('init')

data:extend(
    {
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_1_result,
            order = TemporaryLogisticRequest.prefix_with_mod_name('01'),
            key_sequence = "ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_5_results,
            order = TemporaryLogisticRequest.prefix_with_mod_name('02'),
            key_sequence = "ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_1_ingredients,
            order = TemporaryLogisticRequest.prefix_with_mod_name('03'),
            key_sequence = "CONTROL + ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_5_ingredients,
            order = TemporaryLogisticRequest.prefix_with_mod_name('04'),
            key_sequence = "CONTROL + ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        }
    }
)
