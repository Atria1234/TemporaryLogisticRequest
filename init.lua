TemporaryLogisticRequest = { }

TemporaryLogisticRequest.mod_name = 'TemporaryLogisticRequest'

function TemporaryLogisticRequest.prefix_with_mod_name(value)
    return TemporaryLogisticRequest.mod_name..'__'..value
end

TemporaryLogisticRequest.hotkey_names = {
    request_1_result = TemporaryLogisticRequest.prefix_with_mod_name('increase-request'),
    request_5_results = TemporaryLogisticRequest.prefix_with_mod_name('increase-request-5'),
    request_1_ingredients = TemporaryLogisticRequest.prefix_with_mod_name('increase-request-recipe-ingredients'),
    request_5_ingredients = TemporaryLogisticRequest.prefix_with_mod_name('increase-request-recipe-ingredients-5')
}

TemporaryLogisticRequest.setting_names = {
    fulfilled_request_check_rate = TemporaryLogisticRequest.prefix_with_mod_name('fulfiled-request-check-rate')
}

function TemporaryLogisticRequest.get_logistic_section_name(player)
    return player.name..'\'s temporary requests'
end
