actions :create, :delete
default_action :create

attribute :mount_point, kind_of: String, name_attribute: true
attribute :remote_path, kind_of: String, default: "/scpr/media"
