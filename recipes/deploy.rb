include_recipe 'deploy'
include_recipe 'runit'

node[:deploy].each do |application, deploy|
  if application != node['monkeybar']['application_name']
    Chef::Log.debug("Skipping monkeybar application #{application}")
    next
  end

  opsworks_deploy_dir do
    user root
    group root
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  current_dir = ::File.join(deploy[:deploy_to], 'current')

  opsworks_monkeybar do
    deploy_data deploy
    app application
  end

  ["#{node[:monkeybar][:application_name]}"].each do |s|
    execute "/sbin/sv restart #{s}" do
    end
  end
end
