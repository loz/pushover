#!/bin/bash

case $1 in
  console)
    echo "Starting IRB Console"
    irb -I./ -rconfig/environment
    ;;
esac
