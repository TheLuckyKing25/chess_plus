class_name ConfigFileHandler


var config:ConfigFile = ConfigFile.new()


func set_config_with_dictionary(dict: Dictionary):
	for section in dict.keys():
		for key in dict.get(section).keys():
			config.set_value(section,key,dict.get(section).get(key))
