
#!/bin/bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.12/deploy/gatekeeper.yaml
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper-library/master/library/pod-security-policy/privileged/template.yaml

