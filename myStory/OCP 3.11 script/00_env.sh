### Default Setting
DATETIME=`date +%Y%m%d%H%M%S`
INSTALL_USER=root
BASE_IP=10.0.0.70
BASE_DIR=/root/install/OCP
OCP_HOSTNAME=${BASE_DIR}/config/ocp_hostname
OCP_HOSTNAME_ALL=${BASE_DIR}/config/ocp_hostname_all
OCP_IP=${BASE_DIR}/config/ocp_ip
OCP_IP_ALL=${BASE_DIR}/config/ocp_ip_all

### REPOSITORY
#REPO_PATH="\/root\/repos\/rhel-7-server-rpms"
#REPO_PATH="\/root\/\.pentalink\/repos\/rhel-7-server-rpms"
REPO_PATH="\/var\/www\/html\/repos\/rhel-7-server-rpms"
REPO_IP=10.0.0.210

### DNS
DNS_IP=10.0.0.210
DNS_DOMAIN=test.cloud

### NetWork
#NW_NAME="System\ eth0"
NW_PREFIX=24
NW_GATEWAY=10.0.0.1
NW_DNS1=${DNS_IP}
NW_DNS_SEARCH=${DNS_DOMAIN}
#NW_MTU=1496

### CHRONY
CHRONY_SERVER=10.0.0.210

### DOCKER
DOCKER_DEVS=/dev/vdb

### DOCKER-DISTRIBUTION
DD_IP=10.0.0.80
DD_ADDR=registry.test.cloud
DD_PORT=5000
ROOTDIRECTORY="\/volumes"
CERT_PATH="\/volumes\/cert"

### User Check
UNAME=`whoami`
if [ "e${UNAME}" != "e${INSTALL_USER}" ] && [ "e${1}" != "enoCheck" ];
then
  echo "\"${UNAME}\" is not the same as the install account. (${INSTALL_USER})"
  exit;
fi
