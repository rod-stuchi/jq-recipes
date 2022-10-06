#!/bin/bash

kubectl get ing -ojson \
    | jq -r '.items[] | select(.spec.tls != null) | "\(.metadata.name);\(.spec.tls[] | .secretName)"' \
    | column -t -s";" \
    | sort -k2,3
