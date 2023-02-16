#!/bin/bash

# Read values from config.json
config=$(jq -r 'to_entries | map("\(.key)=\(.value)") | join("\n")' input.json)

echo $config

# Write values to configmap.yaml
cat > configmap.yaml << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
EOF

echo "$config" | while read -r line; do
    key="$(echo "$line" | cut -d '=' -f 2)"
    if [ "${key: -3}" = "key" ]; then
        echo $key
    else
        echo "Last 3 characters of key do not match 'key'"
    fi
    value="$(echo "$line" | cut -d '=' -f 2)"
    echo "  $value: \"$value\"" >> configmap.yaml
done
