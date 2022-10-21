#!/usr/bin/env bash

while read -r l; do
    IFS=';' read -r url proto <<< "$l"
    if [[ ${url} =~ .*"-pwa".* ]]; then
        echo "$url"
        if [ $proto == "allow-all" ]; then
            echo "    💥 ${proto}"
        else
            echo "    📗 ${proto}"
            curl -s -w '%{http_code}, %{redirect_url}\n' -o /dev/null ${url} | sed 's/^/     🔗 /'
        fi
    fi
done < <(aws cloudfront list-distributions \
    | jq -r '.DistributionList.Items[] | "\(.Aliases.Items[]); \(.DefaultCacheBehavior.ViewerProtocolPolicy)"' | sort -k2,3
)

