action :create do
  # make sure the appropriate nfs pieces are installed
  run_context.include_recipe "apt"
  package "nfs-common"

  # Create the mount point
  directory new_resource.mount_point do
    action :create
    recursive true

    # This gets turned into a mount point after the first run,
    # and then the NFS complains if you try to create it again.
    not_if { ::File.exists?(new_resource.mount_point) }
  end

  # Mount static-media on this VM
  mount new_resource.mount_point do
    fstype "nfs"
    device "#{node.scpr_tools.media_nfs_ip}:#{new_resource.remote_path}"
    action [:mount, :enable]
  end
end

action :delete do
  mount new_resource.mount_point do
    action [:umount,:disable]
  end

  directory new_resource.mount_point do
    action :delete
    recursive true
  end
end
