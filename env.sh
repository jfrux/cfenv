#!/bin/bash

# This file sets up paths and basic environment for the Railo dev environment,
# and is intended to be sourced in your shell profile.

set +e
set +u

# Make the root of Railo available.
export CFENV_ROOT=$HOME/.cfenv

# Add railo'd stuff to the path.
PATH=$CFENV_ROOT/libexec:$PATH