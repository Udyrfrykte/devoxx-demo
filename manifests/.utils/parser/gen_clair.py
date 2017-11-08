#! /usr/bin/env python3
# encoding: utf-8

from parser import *

gitlab_registry_url = os.environ.get('CI_REGISTRY')
if gitlab_registry_url is None:
    print('please set the CI_REGISTRY environment variable')
    sys.exit(1)

gitlab_registry_repository = gitlab_registry_url + '/' + loaded_yaml['repository']
for tag, commit in loaded_yaml['tags'].items():
    commit_image = gitlab_registry_repository + ':' + commit
    print('#', commit_image)
    print('klar ' + commit_image + ' > clair_output/' + os.path.basename(args.manifest) + '.' + tag + '.clair.txt')
    print()

sys.exit(0)
