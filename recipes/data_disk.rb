if node.scpr_tools.data_disk
  package "lvm2"

  # -- make sure fstype is supported -- #

  resizebin = nil

  case node.scpr_tools.data_disk.fstype
  when "ext4"
    resizebin = "/sbin/resize2fs"
  when "xfs"
    package "xfsprogs"

    resizebin = "/sbin/xfs_growfs"
  else
    raise "scpr_tools_data_disk: Unsupported fstype #{ node.scpr_tools.data_disk.fstype }"
  end

  # Install the grow_data_disk script

  cookbook_file "/etc/init/scpr_tools_data_disk.conf" do
    action  :create
    mode    0644
  end

  service "scpr_tools_data_disk" do
    supports  [:enable,:start]
    action    :enable
    provider  Chef::Provider::Service::Upstart
  end

  # -- write our script -- #

  template "/usr/local/bin/scpr_tools_data_disk" do
    action    :create
    mode      0755
    notifies  :start, "service[scpr_tools_data_disk]", :immediately
    variables({
      :data_disk  => node.scpr_tools.data_disk.disk,
      :mount      => node.scpr_tools.data_disk.mount,
      :label      => node.scpr_tools.data_disk.label,
      :vglabel    => node.scpr_tools.data_disk.vglabel || node.scpr_tools.data_disk.label,
      :fstype     => node.scpr_tools.data_disk.fstype,
      :resize_bin => resizebin,
    })
  end

else
  file "/etc/init/scpr_tools_data_disk.conf" do
    action :delete
  end
end