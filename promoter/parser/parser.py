#! /usr/bin/env python3
# encoding: utf-8

import sys
import os
import argparse
import yaml

parser = argparse.ArgumentParser(description="parse a registry release manifest")
parser.add_argument("manifest", metavar="MANIFEST", help="the manifest (YAML format)")

args = parser.parse_args()

with open(args.manifest, 'r', encoding='utf-8') as stream:
    try:
        loaded_yaml = yaml.load(stream)
    except yaml.YAMLError as exc:
        print(exc)

print('#', 'Maintainers :')
for maintainer in loaded_yaml['maintainers']:
    print('#', maintainer)

print()
