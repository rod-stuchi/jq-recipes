#!/bin/bash

while read line; do
    item=$(echo $line | base64 -d)
    name=$(echo $item | jq -r '.ing')
    echo -e "🔗 \x1b[48;5;124m$name\x1b[0m"
    for h in $(echo $item | jq -r '.hosts[]'); do
        echo -e "    \x1b[1;38;5;45m$h\x1b[0m"
        dig +short $h | sed 's/^/        /'
    done
done < <(
    kubectl get ing -ojson \
        | jq -r '
        [
            .items[] 
            | select(.metadata.name | contains("pwa"))
            | {name: .metadata.name ,hosts: .spec.rules[] | .host}
        ] | map(select(.hosts | contains("dialog.") | not)) 
          | group_by(.name) 
          | map({ing: .[0].name, hosts: map(.hosts) })
          | map(@base64)[]
        '
)
