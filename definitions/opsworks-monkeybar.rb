define :opsworks_monkeybar do
  deploy = params[:deploy_data]
  application = params[:app]

  execute "/usr/local/bin/npm install" do
    cwd "#{deploy[:deploy_to]}/current"
  end

  execute "/usr/local/bin/npm config set user 0" do
    cwd "#{deploy[:deploy_to]}/current"
  end

  execute "./node_modules/grunt-cli/bin/grunt build" do
    cwd "#{deploy[:deploy_to]}/current"
  end
  
  ldir = '/var/log'
  ['/etc/sv', "#{ldir}/#{node[:monkeybar][:application_name]}"].each do |d|
    directory d do
      action :create
      owner "root"
      group "root"
      mode "0755"
      recursive true
    end
  end

  ["#{node[:monkeybar][:application_name]}"].each do |d|
    template "#{ldir}/#{d}/config" do
      source "sv-#{d}-log-conf.erb"
      mode '0644'
    end
  end

  runit_service "#{node[:monkeybar][:application_name]}"
end
