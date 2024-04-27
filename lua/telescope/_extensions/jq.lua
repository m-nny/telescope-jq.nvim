return require("telescope").register_extension({
	setup = function(ext_config, config) end,
	exports = {
		current_file = require("jq").current_file,
	},
})
