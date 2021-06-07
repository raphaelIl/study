## ES 운영시 cluster 재시작 Guide

- https://www.popit.kr/%EC%97%98%EB%9D%BC%EC%8A%A4%ED%8B%B1%EC%84%9C%EC%B9%98es-%ED%81%B4%EB%9F%AC%EC%8A%A4%ED%84%B0-%EC%9E%AC%EC%8B%9C%EC%9E%91-%ED%98%B9%EC%9D%80-%EC%97%85%EA%B7%B8%EB%A0%88%EC%9D%B4%EB%93%9C-tip/
- https://www.elastic.co/guide/en/elasticsearch/reference/current/restart-cluster.html#restart-cluster-rolling

es_ver: 5.6

elasticsearch 서비스 무중단 update를 위해 어떻게 했는지 기록해본다.

### 0. Update Images

> 문서엔 단일 노드마다 데몬을 끄는것으로 나온다.  
> 어떻게 구현하는가?

sts에서 .spec.updateStrategy(OnDelete)를 활용한다.  
OnDelete로 적용하면 내가 수동으로 pod를 제거한다는 뜻이다.  
https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#on-delete

```sh
# kubectl rollout restart sts ${sts_name}
kubectl apply -f ${file_name}
```

</br>

### 1. Disable shard allocation.

https://www.elastic.co/guide/en/elasticsearch/reference/5.6/shards-allocation.html#_shard_allocation_settings

```sh
curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
    -H "Content-Type: application/json" \
    -d '{"persistent":{"cluster.routing.allocation.enable":"none"}}'
```

</br>

### 2. Stop indexing and perform a synced flush.

```sh
curl -X POST "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_flush/synced"
```

</br>

### 3. Rolling restart

수동 삭제 및 필요한 기능 sh에 구현  
</br>

### 4. Restart the node you changed.

```sh
GET _cat/nodes
```

</br>

### 5. Reenable shard allocation.

```sh
curl -X PUT "${ELASTICSEARCH_CLUSTER_ENDPOINT}/_cluster/settings" \
    -H "Content-Type: application/json" \
    -d '{"persistent":{"cluster.routing.allocation.enable":"all"}}'
```
