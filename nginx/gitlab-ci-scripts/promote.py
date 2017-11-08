#!/usr/bin/env python3
# encoding: utf-8

from urllib.request import Request, urlopen

import json
import pprint
import sys
import argparse

#token="fN5oMTp2ZmsLVULA94P7"
#base_url="https://gitlab.udd.bogops.io"
#source_project="devs/manifests"
#target_project="admins/manifests"
#source_branch="metrics-app"
#target_branch="master"

parser = argparse.ArgumentParser(description="parse a registry release manifest")
parser.add_argument("token",          metavar="TOKEN",          help="PRIVATE_TOKEN")
parser.add_argument("base_url",       metavar="BASE_URL",       help="example: https://gitlab.udd.bogops.io")
parser.add_argument("source_project", metavar="SOURCE_PROJECT", help="Name of source project (devs/manifests)")
parser.add_argument("target_project", metavar="TARGET_PROJECT", help="Name of source project (admins/manifests)")
parser.add_argument("source_branch",  metavar="SOURCE_BRANCH",  help="metrics-app")
parser.add_argument("target_branch",  metavar="TARGET_BRANCH",  help="master")

args = parser.parse_args()

def get_gitlab_url(endpoint):
    req = Request(args.base_url + endpoint)
    req.add_header('PRIVATE-TOKEN', args.token)
    response = urlopen(req)
    return json.load(response)

def post_gitlab_url(endpoint, payload):
    req = Request(args.base_url + endpoint, json.dumps(payload).encode('UTF-8'), {'Content-Type': 'application/json'})
    req.add_header('PRIVATE-TOKEN', args.token)
    response = urlopen(req)
    return json.load(response)

projects = {}
for p in get_gitlab_url('/api/v4/projects/'):
    projects[p["web_url"].replace(args.base_url + "/" ,"")] = int(p["id"])

assert args.source_project in projects
assert args.target_project in projects

found_merge_request = 0
for mr in get_gitlab_url("/api/v4/projects/%d/merge_requests/?state=opened"%projects[args.target_project]):
    if mr["source_project_id"] == projects[args.source_project] and mr['source_branch'] ==  args.source_branch:
        found_merge_request = int(mr["id"])
        break

if found_merge_request != 0:
    print("I have to update MR %d"%found_merge_request)
else:
    print("No previous MR found, creating a new one")
    # Create a new MR
    r = post_gitlab_url("/api/v4/projects/%d/merge_requests/"%projects[args.source_project],
            {
                "source_branch": args.source_branch,
                "target_branch": args.target_branch,
                "remove_source_branch": True,
                "target_project_id": projects[args.target_project],
                "title": "Merge update for %s"%args.source_branch
            })
    pprint.pprint(r)

