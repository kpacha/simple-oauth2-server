class common{
  # Common packages
  $common_packages = [
    # Linux
    'build-essential',

    # Utilities
    'curl',
    'libaio1',
    'libcurl3',
    'libnss3-1d',
    'unzip',
  ]
  package { $common_packages:
    ensure => installed,
  }
}