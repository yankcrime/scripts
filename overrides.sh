#!/usr/bin/env bash
xcape -e Control_L=Escape
xset r rate 300 30
systemctl --user restart imwheel
