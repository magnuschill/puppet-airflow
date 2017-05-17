# == Class: airflow::install
# == Description: Install airflow python package using pip.
#
class airflow::install inherits airflow {
  # Install airflow python package
  if $airflow::package_manage {
    # for backwards compatibility with variable "version", remove in a breaking version
    if $airflow::version {
      warning("use of the parameter airflow::version is deprecated, please use airflow::package_ensure")
      $ensure_value = $airflow::version
    }
    else {
      $ensure_value = $airflow::package_ensure
    }

    package { $airflow::package_name:
      ensure => $ensure_value,
      provider => $airflow::package_provider
    }

  }
}
