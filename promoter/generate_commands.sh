#! /bin/bash
set -e

# we need an UTF-8 compatible locale
# locale-gen en_US.utf8
# export LANG="en_US.utf8"

GITLAB_URL="$(echo "$CI_PROJECT_URL" | cut -d '/' -f 3)"

git clone "https://gitlab-ci-token:${CI_JOB_TOKEN}@${GITLAB_URL}/admins/manifests.git" library

repos=( $(ls -1 library) )

echo '#! /bin/bash' >| notary_commands.sh
echo 'set -e' >> notary_commands.sh
echo >> notary_commands.sh

for repo in "${repos[@]}"; do
  parser/gen_notary.py library/${repo} >> notary_commands.sh
  echo >> notary_commands.sh
  echo >> notary_commands.sh
done

echo '#! /bin/bash' >| notary_publish_commands.sh
echo 'set -e' >> notary_publish_commands.sh
echo >> notary_publish_commands.sh

for repo in "${repos[@]}"; do
  parser/gen_notary_publish.py library/${repo} >> notary_publish_commands.sh
  echo >> notary_publish_commands.sh
  echo >> notary_publish_commands.sh
done

echo '#! /bin/bash' >| docker_commands.sh
echo 'set -e' >> docker_commands.sh
echo >> docker_commands.sh

for repo in "${repos[@]}"; do
  parser/gen_docker.py library/${repo} >> docker_commands.sh
  echo >> docker_commands.sh
  echo >> docker_commands.sh
done

cat notary_commands.sh
cat docker_commands.sh
