config.cache_classes = true
config.log_path = INSTALLER_OPTIONS[ :log_file_name ] || 'log/installer_WITHOUT_A_NAME.log'
config.log_level = INSTALLER_OPTIONS[ :verbose ] ? :debug : :info
