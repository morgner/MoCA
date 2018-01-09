#! /usr/bin/env bash

export PYTHONPATH=moca 
export FLASKR_SETTINGS=setup.py
export FLASK_APP=moca
#export FLASK_DEBUG=true

flask run

