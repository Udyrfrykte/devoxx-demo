#! /bin/bash
set -e

# we need an UTF-8 compatible locale
# locale-gen en_US.utf8
# export LANG="en_US.utf8"

if [ "$CI_PROJECT_PATH" = "admins/manifests" ]; then
  echo 'on main repo, switching to full verification'
  repos=( $(ls -1 .. | grep -v '.utils' | grep -v '.gitlab-ci.yml' | grep -v '.gitignore' || true) )
else
  GITLAB_URL="$(echo "$CI_PROJECT_URL" | cut -d '/' -f 3)"
  HEAD="$(git rev-parse --verify HEAD)"
  UPSTREAM="$(git ls-remote "https://gitlab-ci-token:${CI_JOB_TOKEN}@${GITLAB_URL}/admins/manifests.git" master | cut -f 1)"
  git diff --numstat "$UPSTREAM...$HEAD" -- ..
  repos=( $(git diff --numstat "$UPSTREAM...$HEAD" -- .. | sed 's/^[0-9][0-9]*[[:space:]][[:space:]]*[0-9][0-9]*[[:space:]][[:space:]]*//' | grep -v '.utils' | grep -v '.gitlab-ci.yml' | grep -v '.gitignore' || true) )
fi

echo "Manifests that will be checked:"
echo "$repos"

echo '#! /bin/bash' >| clair_commands.sh
echo 'set -e' >> clair_commands.sh
echo >> clair_commands.sh

for repo in "${repos[@]}"; do
  parser/gen_clair.py ../${repo} >> clair_commands.sh
  echo >> clair_commands.sh
done

mv clair_commands.sh ..
cat ../clair_commands.sh
