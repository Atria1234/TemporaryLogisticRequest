require('init')

data:extend(
    {
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_1_result,
            order = "TemporaryLogisticRequest__01",
            key_sequence = "ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_5_results,
            order = "TemporaryLogisticRequest__02",
            key_sequence = "ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_1_ingredients,
            order = "TemporaryLogisticRequest__03",
            key_sequence = "CONTROL + ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = TemporaryLogisticRequest.hotkey_names.request_5_ingredients,
            order = "TemporaryLogisticRequest__04",
            key_sequence = "CONTROL + ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        }
    }
)
