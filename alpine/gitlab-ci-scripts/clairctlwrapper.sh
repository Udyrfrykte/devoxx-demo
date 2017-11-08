#!/usr/bin/env bash

mkdir -p /etc/ssl/certs

cp $(dirname "$0")/ca-certificates.crt /etc/ssl/certs

cat > /clairctl.yml <<EOF
clair:
  port: 443
  healthPort: 6061
  uri: $CLAIR_ADDR
  report:
    path: ./reports
    format: html
EOF

mkdir /root/.docker
cat > /root/.docker/config.json <<EOF
{
	"auths": {
		"$CI_REGISTRY": {
      "auth": "$(/bin/echo -n "gitlab-ci-token:$CI_BUILD_TOKEN" | base64)"
		}
	}
}
EOF
env
echo $HOME
cat /root/.docker/config.json
/clairctl --config /clairctl.yml report $1
