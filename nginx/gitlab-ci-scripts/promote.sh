#!/usr/bin/bash

#CI_PROJECT_URL=https://gitlab.udd.bogops.io/devs/metrics-app
#CI_JOB_TOKEN=test1Atest
#CI_COMMIT_SHA=dcffa8b4016f76232c45b6c48f1e2a8a91b56afe
#CI_PROJECT_NAME=metrics-app
#CI_PROJECT_PATH=devs/metrics-app
#PROJECT_DIR=$(pwd)
BIN_DIR=$(dirname "$0")

login=$DEV_BOT_LOGIN
#login=dev-a
password=$DEV_BOT_PASS
url_no_protocol=${CI_PROJECT_URL/https:\/\//}
url=${url_no_protocol%%/*}
git clone https://$login:$password@$url/devs/manifests
pushd manifests
git config user.email "$GITLAB_USER_EMAIL"
git config user.name "${GITLAB_USER_EMAIL%%@*}"
git remote add upstream https://$login:$password@$url/admins/manifests
git pull --rebase upstream master
git push origin master
if git ls-remote --exit-code https://$login:$password@$url/devs/manifests $CI_PROJECT_NAME; then
  git checkout $CI_PROJECT_NAME --
  git rebase master
else
  git checkout -b $CI_PROJECT_NAME
fi

cat > $CI_PROJECT_NAME <<EOF
---

maintainers:
$(cat $CI_PROJECT_DIR/maintainers | while read i; do
echo "- $i"
done)

repository: '$CI_PROJECT_PATH'

tags:
$(cat $CI_PROJECT_DIR/versions | while read i; do
echo "  '$i': $CI_COMMIT_SHA"
done)
EOF

url=${url_no_protocol%%/*}
git add $CI_PROJECT_NAME
git commit -m "Promote $CI_PROJECT_PATH@$CI_COMMIT_SHA"
git push --force origin $CI_PROJECT_NAME
popd
$BIN_DIR/promote.py fN5oMTp2ZmsLVULA94P7 https://$url devs/manifests admins/manifests $CI_PROJECT_NAME master
