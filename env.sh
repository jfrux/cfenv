#!/bin/bash

# This file sets up paths and basic environment for the Railo dev environment,
# and is intended to be sourced in your shell profile.

set +e
set +u

# Make the root of Railo available.
export CFENV_ROOT=$HOME/.cfenv

# Add railo'd stuff to the path.
PATH=$CFENV_ROOT:$PATH

# FOR MORE GOODIES LATER...
# for f in $CFENV_ROOT/env.d/*.sh ; do
#   if [ -f $f ] ; then
#     source $f
#   fi
# done

# Cfenv is installed.
if [ -d "$CFENV_ROOT/.git" ]; then
  export CFENV_SETUP_VERSION=`GIT_DIR=$CFENV_ROOT/.git git rev-parse --short HEAD`
else
  echo "cfenv could not load properly!"
fi
