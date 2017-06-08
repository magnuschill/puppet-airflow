# define: airflow::resource::service
# == Description: Creates a systemd service definition
#
define airflow::resource::service(
  $service_name     = $name,
  $run_folder       = $airflow::run_folder,
  $gunicorn_workers = $airflow::gunicorn_workers,
  $web_server_host  = $airflow::web_server_host,
  $web_server_port  = $airflow::web_server_port,
  $home_folder      = $airflow::home_folder,
  $user             = $airflow::user,
  $group            = $airflow::group
) {
  if $::osfamily == 'RedHat'{
    if $::operatingsystemmajrelease == '7'{
      # Systemd
      include systemd
      file { "${airflow::systemd_service_folder}/${service_name}.service":
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/${service_name}.service.erb"),
        require => [Package[$airflow::package_name], File[$airflow::log_folder]]
      }
      ~> Exec['systemctl-daemon-reload']
      service { $service_name:
        ensure    => $airflow::service_ensure,
        enable    => $airflow::service_enable,
        subscribe =>
        [
          File["${airflow::systemd_service_folder}/${service_name}.service"],
          File["${airflow::home_folder}/airflow.cfg"]
        ]
      }
    } else {
      # SysV
      $cmd_parts = split($service_name, '-')
      $basic_command = $cmd_parts[1]
      if $service_name == 'airflow-webserver' {
        $command = "${basic_command} -w=${gunicorn_workers} -t 120 -hn=${web_server_host} -p=${web_server_port}"
      } else {
        $command = $basic_command
      }
      file { "/etc/init.d/${service_name}":
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        content => template("${module_name}/service.sysv.erb"),
        require => [Package[$airflow::package_name], File[$airflow::log_folder]]
      }
      service { $service_name:
        ensure    => $airflow::service_ensure,
        enable    => $airflow::service_enable,
        subscribe =>
        [
          File["/etc/init.d/${service_name}"],
          File["${airflow::home_folder}/airflow.cfg"]
        ]
      }
    }
  } else {
    alert('Service management unsupported for your OS family')

  }
}
