#!/usr/bin/env bash

# Do some additonal cleanup and messing around once env is up and
#  all scripts have run.

# Create a symlink `var` directory in the current user directory 
#   ;) makes it easier to access app files under `var`
ln -s /${USER}/var/ /home/${USER}/var