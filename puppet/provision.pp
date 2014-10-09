# ===
# Install and Run Couchbase Server
# ===

$couchN1QLPackage = "https://s3.amazonaws.com/query-dp3/couchbase-query_dev_preview3_x86_64_linux.tar.gz"
$splitter0 = split($couchN1QLPackage, '/')
$couchN1QLFilename = $splitter0[-1]

$couchPackage = "http://packages.couchbase.com/releases/3.0.0/couchbase-server-community_3.0.0-ubuntu12.04_amd64.deb"
$splitter1 = split($couchPackage, '/')
$couchFilename = $splitter1[-1]

# Create a directory      
file { "/vagrant/couch":
  ensure => "directory",
  before => Exec["couchbase-server-source","couchbase-n1ql-server-source"]
}

# Download Couchbase
exec { "couchbase-server-source": 
  command => "/usr/bin/wget $couchPackage",
  cwd => "/vagrant/couch",   
  creates => "/vagrant/couch/$couchFilename",
  before => Package['couchbase-server']
}

# Download Couchbase N1QL
exec { "couchbase-n1ql-server-source":
  command => "/usr/bin/wget $couchN1QLPackage",
  cwd => "/vagrant/couch",
  creates => "/vagrant/couch/$couchN1QLFilename"
}

# Create a directory      
file { "/vagrant/couch/N1QL":
  ensure => "directory",
  before => Exec["couchbase-n1ql-server-extract"]
}

# Extract N1QL
exec {"couchbase-n1ql-server-extract": 
  command => "tar xvzf $couchN1QLFilename -C /vagrant/couch/N1QL",
  cwd => "/vagrant/couch",   
  creates => "/vagrant/couch/N1QL/start_tutorial.sh",
  path    => ["/usr/bin", "/usr/sbin", "/bin"]
}

# Update the System
exec { 
  "apt-get update": path => "/usr/bin"
}

# Install libssl dependency
package { "libssl0.9.8":
  name => "libssl0.9.8",
  ensure => present,
  before => Package["couchbase-server"]
}

# Install Couchbase Server
package { "couchbase-server":
  provider => dpkg,
  ensure => installed,
  source => "/vagrant/couch/$couchFilename",
}

# Ensure the service is running
service { "couchbase-server":
	ensure => "running",
	require => Package["couchbase-server"]
}

# Start N1QL
#exec {"couchbase-n1ql-server-start": 
#  command => "/vagrant/couch/N1QL/start_tutorial.sh &",
#  cwd => "/vagrant/couch/N1QL",
#  require => Exec["couchbase-n1ql-server-extract"]
#}



