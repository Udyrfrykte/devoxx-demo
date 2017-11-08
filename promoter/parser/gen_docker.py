#! /usr/bin/env python3
# encoding: utf-8

from parser import *

gitlab_registry_url = os.environ.get('CI_REGISTRY')
if gitlab_registry_url is None:
    print('please set the CI_REGISTRY environment variable')
    sys.exit(1)

prod_registry_url = os.environ.get('PROD_REGISTRY')
if prod_registry_url is None:
    print('please set the PROD_REGISTRY environment variable')
    sys.exit(1)

gitlab_registry_repository = gitlab_registry_url + '/' + loaded_yaml['repository']
prod_registry_repository = prod_registry_url + '/' + loaded_yaml['repository']

for tag, commit in loaded_yaml['tags'].items():
    print('#', gitlab_registry_repository + ':' + commit, '=>', prod_registry_repository + ':' + tag)
    print('export DOCKER_CONTENT_TRUST=0')
    print('docker pull', gitlab_registry_repository + ':' + commit)
    print('docker tag', gitlab_registry_repository + ':' + commit, prod_registry_repository + ':' + tag)
# pre-push to make time more deterministic
    print('docker push', prod_registry_repository + ':' + tag)
    print('export DOCKER_CONTENT_TRUST=1')
    print('expect -f trusted_docker_push.exp', prod_registry_repository + ':' + tag)
#    print('(echo "$NOTARY_TARGETS_PASSPHRASE" && sleep 20 && echo "$NOTARY_SNAPSHOT_PASSPHRASE") | docker push', prod_registry_repository + ':' + tag)
    print()

sys.exit(0)
