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
  $group            = $airflow::group,
) {
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
}
