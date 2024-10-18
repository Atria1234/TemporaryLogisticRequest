require('init')

data:extend(
{
	{
		name = TemporaryLogisticRequest.setting_names.fulfilled_request_check_rate,
		type = "int-setting",
		setting_type = "runtime-global",
		default_value = 60,
		minimum_value = 1,
		order = "1"
	}
})
