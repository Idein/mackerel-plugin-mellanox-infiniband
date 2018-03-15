mackerel-plugin-mellanox-infiniband
===================================

mellanox infiniband transmitted/recieved metric plugin for mackerel.io agent

This plugin monitors `/sys/class/infiniband/mlx*/ports/*/counters/{port_rcv_data,port_xmit_data}`

## Synopsis

```shell
mackerel-plugin-mellanox-infiniband
```

## Example of mackerel-agent.conf

```
[plugin.metrics.infiniband]
command = "/path/to/mackerel-plugin-mellanox-infiniband"
```
