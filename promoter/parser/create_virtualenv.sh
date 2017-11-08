#! /bin/bash

virtualenv --python=python3 virtualenv
source virtualenv/bin/activate
pip install -r requirements.txt
