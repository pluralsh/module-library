# ClickHouse

This chart installs a ClickHouse server using the Altinity clickhouse-operator.
It is originally based on the templates used by the PostHog helm chart, but modified to allow for using ClickHouse-Keeper.

To install:

```bash
helm repo add plural-modules https://pluralsh.github.io/module-library
helm repo update
helm install plural-modules/clickhouse --set pluralRunbook.enabled=false
```

This chart allow for easily enabling the built-in ClickHouse-Keeper by setting `clickhouseKeeper.enabled: true`.
When ClickHouse-Keeper is enabled, each shard is set to have 3 replicas and the replicas of the first shard run ClickHouse-Keeper.

By setting `defaultTopologySpreadConstraints.enabled`, the clickhouse pods will be distributed across availability zones automatically (useful for AWS EBS).
