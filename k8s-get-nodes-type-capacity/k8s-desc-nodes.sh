#!/bin/bash

tmp=$(mktemp)
# echo "temp: $tmp"
kubectl get pods --all-namespaces -ojson > $tmp

while read -r line; do
    ljson=$(echo "$line" | base64 -d)
    node=$(jq -r '.name' < <(echo $ljson))

    cap_mem=$(jq -r '.cap_mem' < <(echo $ljson))
    cap_mem=$(echo "${cap_mem}" | sed 's/Ki//')
    cap_mem=$(echo "${cap_mem} / 1000 / 1000" | bc)
    cap_mem=$(echo "${cap_mem}Gb")

    all_mem=$(jq -r '.all_mem' < <(echo $ljson))
    all_mem=$(echo "${all_mem}" | sed 's/Ki//')
    all_mem=$(echo "${all_mem} / 1000 / 1000" | bc)
    all_mem=$(echo "${all_mem}Gb")

    pod_in_node=$(jq ".items | map(select(.spec.nodeName == \"${node}\")) | length" $tmp)

    echo "$ljson" | jq ". += {\"🏃 pods\": \"${pod_in_node}\", \"cap_mem\": \"${cap_mem}\", \"all_mem\": \"${all_mem}\"}"
done < <(
    kubectl get nodes -ojson | jq -r -c '.items[]
      | {
          name: .metadata.labels."kubernetes.io/hostname",
          type: .metadata.labels."node.kubernetes.io/instance-type",
          cap_cpu: .status.capacity.cpu,
          all_cpu: .status.allocatable.cpu,
          cap_mem: .status.capacity.memory,
          all_mem: .status.allocatable.memory,
          cap_pod: .status.capacity.pods,
          all_pod: .status.allocatable.pods,
        } | @base64'
) \
    | jq -s '.' | jtbl

rm $tmp
