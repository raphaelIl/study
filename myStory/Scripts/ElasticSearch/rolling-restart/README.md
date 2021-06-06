## ES 운영시 cluster 재시작 Guide

- https://www.popit.kr/%EC%97%98%EB%9D%BC%EC%8A%A4%ED%8B%B1%EC%84%9C%EC%B9%98es-%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0-%EC%9E%AC%EC%8B%9C%EC%9E%91-%ED%98%B9%EC%9D%80-%EC%97%85%EA%B7%B8%EB%A0%88%EC%9D%B4%EB%93%9C-tip/
- https://www.elastic.co/guide/en/elasticsearch/reference/current/restart-cluster.html#restart-cluster-rolling

es_ver: 5.6

### 1. Disable shard allocation.

https://www.elastic.co/guide/en/elasticsearch/reference/5.6/shards-allocation.html#_shard_allocation_settings

```sh
curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
    -H "Content-Type: application/json" \
    -d '{"persistent":{"cluster.routing.allocation.enable":"none"}}'
```

### 2. Stop indexing and perform a synced flush.

```sh
curl -X POST "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_flush/synced"
```

### 3. Rolling restart or Update Images

> 음... 문서엔 단일 노드마다 데몬을 끄는것으로 나온다.

```sh
# or kubectl apply -f ${file_name}
kubectl rollout restart sts ${sts_name}
```

### 4. Restart the node you changed.

```sh
GET _cat/nodes
```

### 5. Reenable shard allocation.

```sh
curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
    -H "Content-Type: application/json" \
    -d '{"persistent":{"cluster.routing.allocation.enable":"all"}}'
```
