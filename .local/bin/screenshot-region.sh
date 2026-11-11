#!/bin/bash
grim -g "$(slurp)" - | satty --filename - >> /tmp/satty.log 2>&1
