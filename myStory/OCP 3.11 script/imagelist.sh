tag=v3.11.104

# required image list

docker pull registry.redhat.io/openshift3/apb-base:$tag
docker pull registry.redhat.io/openshift3/apb-tools:$tag
docker pull registry.redhat.io/openshift3/automation-broker-apb:$tag
docker pull registry.redhat.io/openshift3/csi-attacher:$tag
docker pull registry.redhat.io/openshift3/csi-driver-registrar:$tag
docker pull registry.redhat.io/openshift3/csi-livenessprobe:$tag
docker pull registry.redhat.io/openshift3/csi-provisioner:$tag
docker pull registry.redhat.io/openshift3/grafana:$tag
docker pull registry.redhat.io/openshift3/local-storage-provisioner:$tag
docker pull registry.redhat.io/openshift3/manila-provisioner:$tag
docker pull registry.redhat.io/openshift3/mariadb-apb:$tag
docker pull registry.redhat.io/openshift3/mediawiki:$tag
docker pull registry.redhat.io/openshift3/mediawiki-apb:$tag
docker pull registry.redhat.io/openshift3/mysql-apb:$tag
docker pull registry.redhat.io/openshift3/ose-ansible-service-broker:$tag
docker pull registry.redhat.io/openshift3/ose-cli:$tag
docker pull registry.redhat.io/openshift3/ose-cluster-autoscaler:$tag
docker pull registry.redhat.io/openshift3/ose-cluster-capacity:$tag
docker pull registry.redhat.io/openshift3/ose-cluster-monitoring-operator:$tag
docker pull registry.redhat.io/openshift3/ose-console:$tag
docker pull registry.redhat.io/openshift3/ose-configmap-reloader:$tag
docker pull registry.redhat.io/openshift3/ose-control-plane:$tag
docker pull registry.redhat.io/openshift3/ose-deployer:$tag
docker pull registry.redhat.io/openshift3/ose-descheduler:$tag
docker pull registry.redhat.io/openshift3/ose-docker-builder:$tag
docker pull registry.redhat.io/openshift3/ose-docker-registry:$tag
docker pull registry.redhat.io/openshift3/ose-efs-provisioner:$tag
docker pull registry.redhat.io/openshift3/ose-egress-dns-proxy:$tag
docker pull registry.redhat.io/openshift3/ose-egress-http-proxy:$tag
docker pull registry.redhat.io/openshift3/ose-egress-router:$tag
docker pull registry.redhat.io/openshift3/ose-haproxy-router:$tag
docker pull registry.redhat.io/openshift3/ose-hyperkube:$tag
docker pull registry.redhat.io/openshift3/ose-hypershift:$tag
docker pull registry.redhat.io/openshift3/ose-keepalived-ipfailover:$tag
docker pull registry.redhat.io/openshift3/ose-kube-rbac-proxy:$tag
docker pull registry.redhat.io/openshift3/ose-kube-state-metrics:$tag
docker pull registry.redhat.io/openshift3/ose-metrics-server:$tag
docker pull registry.redhat.io/openshift3/ose-node:$tag
docker pull registry.redhat.io/openshift3/ose-node-problem-detector:$tag
docker pull registry.redhat.io/openshift3/ose-operator-lifecycle-manager:$tag
docker pull registry.redhat.io/openshift3/ose-ovn-kubernetes:$tag
docker pull registry.redhat.io/openshift3/ose-pod:$tag
docker pull registry.redhat.io/openshift3/ose-prometheus-config-reloader:$tag
docker pull registry.redhat.io/openshift3/ose-prometheus-operator:$tag
docker pull registry.redhat.io/openshift3/ose-recycler:$tag
docker pull registry.redhat.io/openshift3/ose-service-catalog:$tag
docker pull registry.redhat.io/openshift3/ose-template-service-broker:$tag
docker pull registry.redhat.io/openshift3/ose-tests:$tag
docker pull registry.redhat.io/openshift3/ose-web-console:$tag
docker pull registry.redhat.io/openshift3/postgresql-apb:$tag
docker pull registry.redhat.io/openshift3/registry-console:$tag
docker pull registry.redhat.io/openshift3/snapshot-controller:$tag
docker pull registry.redhat.io/openshift3/snapshot-provisioner:$tag
docker pull registry.redhat.io/rhel7/etcd:3.2.22


# optional image list

docker pull registry.redhat.io/openshift3/metrics-cassandra:$tag
docker pull registry.redhat.io/openshift3/metrics-hawkular-metrics:$tag
docker pull registry.redhat.io/openshift3/metrics-hawkular-openshift-agent:$tag
docker pull registry.redhat.io/openshift3/metrics-heapster:$tag
docker pull registry.redhat.io/openshift3/metrics-schema-installer:$tag
docker pull registry.redhat.io/openshift3/oauth-proxy:$tag
docker pull registry.redhat.io/openshift3/ose-logging-curator5:$tag
docker pull registry.redhat.io/openshift3/ose-logging-elasticsearch5:$tag
docker pull registry.redhat.io/openshift3/ose-logging-eventrouter:$tag
docker pull registry.redhat.io/openshift3/ose-logging-fluentd:$tag
docker pull registry.redhat.io/openshift3/ose-logging-kibana5:$tag
docker pull registry.redhat.io/openshift3/prometheus:$tag
docker pull registry.redhat.io/openshift3/prometheus-alertmanager:$tag
docker pull registry.redhat.io/openshift3/prometheus-node-exporter:$tag
docker pull registry.redhat.io/cloudforms46/cfme-openshift-postgresql
docker pull registry.redhat.io/cloudforms46/cfme-openshift-memcached
docker pull registry.redhat.io/cloudforms46/cfme-openshift-app-ui
docker pull registry.redhat.io/cloudforms46/cfme-openshift-app
docker pull registry.redhat.io/cloudforms46/cfme-openshift-embedded-ansible
docker pull registry.redhat.io/cloudforms46/cfme-openshift-httpd
docker pull registry.redhat.io/cloudforms46/cfme-httpd-configmap-generator
docker pull registry.redhat.io/rhgs3/rhgs-server-rhel7
docker pull registry.redhat.io/rhgs3/rhgs-volmanager-rhel7
docker pull registry.redhat.io/rhgs3/rhgs-gluster-block-prov-rhel7
docker pull registry.redhat.io/rhgs3/rhgs-s3-server-rhel7
