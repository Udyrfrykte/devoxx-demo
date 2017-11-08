#! /usr/bin/env python3
# encoding: utf-8

from parser import *

prod_registry_url = os.environ.get('PROD_REGISTRY')
if prod_registry_url is None:
    print('please set the PROD_REGISTRY environment variable')
    sys.exit(1)

prod_registry_repository = prod_registry_url + '/' + loaded_yaml['repository']

print('#', prod_registry_repository, 'initialisation (0<&- closes stdin to force notary in non-interactive mode)')
print('notary list', prod_registry_repository, '||', 'notary init', prod_registry_repository, '0<&-')

sys.exit(0)
