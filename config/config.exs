import Config

# Umbrella-level configuration. Each app contributes its own config under
# `apps/*/config/config.exs`, loaded here so a single `mix` run resolves
# every application's settings.

for config_path <- Path.wildcard("apps/*/config/config.exs") do
  import_config "../#{config_path}"
end

# Environment-specific overrides (dev/test/prod) live alongside this file.
import_config "#{config_env()}.exs"
