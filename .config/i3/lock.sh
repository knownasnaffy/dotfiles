#!/bin/sh

alpha='dd'
background='#15161e'
selection='#1a1b26'
comment='#c0caf5'

yellow='#e0af68'
orange='#e0af68'
red='#f7768e'
magenta='#bb9af7'
blue='#7aa2f7'
cyan='#7dcfff'
green='#9ece6a'

i3lock \
  --insidever-color=$selection \
  --insidewrong-color=$selection \
  --inside-color=$selection \
  --ringver-color=$green$alpha \
  --ringwrong-color=$red$alpha \
  --ringver-color=$green$alpha \
  --ringwrong-color=$red$alpha \
  --ring-color=$background$alpha \
  --line-uses-ring \
  --keyhl-color=$blue$alpha \
  --bshl-color=$orange$alpha \
  --separator-color=$selection$alpha \
  --verif-color=$green \
  --wrong-color=$red \
  --modif-color=$red \
  --layout-color=$blue \
  --date-color=$blue \
  --time-color=$blue \
  --screen 1 \
  --blur 1 \
  --clock \
  --indicator \
  --time-str="%H:%M:%S" \
  --date-str="%A %e %B %Y" \
  --verif-text="" \
  --wrong-text="" \
  --noinput="No Input" \
  --lock-text="" \
  --lockfailed="Lock Failed" \
  --radius=120 \
  --ring-width=10 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys \
 --time-font="JetBrainsMono Nerd Font" \
 --date-font="JetBrainsMono Nerd Font" \
 --layout-font="JetBrainsMono Nerd Font" \
 --verif-font="JetBrainsMono Nerd Font" \
 --wrong-font="JetBrainsMono Nerd Font" \

# These last five lines are commented because they concern the font you want to use.
# JetBrainsMono Nerd Font is the font that was used in the screenshot.
# To specify a favorite font, just uncomment the five lines and replace the parameter with the font you prefer.
