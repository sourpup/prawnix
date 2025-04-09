# Sway Module

sway does not have support for sharing individual windows yet
https://github.com/emersion/xdg-desktop-portal-wlr/issues/107

so we work around this by using a script to create a headless output, put a temp workspace on it, and then use wl-mirror so we can see it on our actual displays
then we can screen share that output
script adapted from
https://github.com/emersion/xdg-desktop-portal-wlr/issues/107#issuecomment-2132150014
and
https://github.com/emersion/xdg-desktop-portal-wlr/issues/107#issuecomment-2168613018
