Settings = Rails.application.config

YAML.load_file("#{Rails.root}/config/settings.yml").each do |k, v|
	Rails.application.config.send "#{k}=", v
end
