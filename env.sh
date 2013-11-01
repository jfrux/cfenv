#!/bin/bash

# This file sets up paths and basic environment for the Railo dev environment,
# and is intended to be sourced in your shell profile.

set +e
set +u

# Make the root of Railo available.
export RAILO_HOME=/opt/railo

# Add railo'd stuff to the path.
PATH=$RAILO_HOME:$PATH

# FOR MORE GOODIES LATER...
# for f in $RAILO_HOME/env.d/*.sh ; do
#   if [ -f $f ] ; then
#     source $f
#   fi
# done

# Railo is installed.
if [ -d "$RAILO_HOME/.git" ]; then
  export RAILO_SETUP_VERSION=`GIT_DIR=$RAILO_HOME/.git git rev-parse --short HEAD`
else
  echo "Railo could not load properly!"
fi
