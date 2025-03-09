# Autogenerated config.py
#
# NOTE: config.py is intended for advanced users who are comfortable
# with manually migrating the config file on qutebrowser upgrades. If
# you prefer, you can also configure qutebrowser using the
# :set/:bind/:config-* commands without having to write a config.py
# file.
#
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

# Change the argument to True to still load settings configured via autoconfig.yml
config.load_autoconfig()
config.source('./themes/tokyonight.py')

# Configure tabs
c.tabs.position = 'top'
c.tabs.title.format = '{audio}{index}: {current_title}'

c.hints.border = '0px'
c.hints.chars = 'asdfjkl;wevnio'
c.hints.radius = 0
c.keyhint.radius = 0
c.prompt.radius = 0

# Load tabs when focused after session start
c.session.lazy_restore = True

#
c.statusbar.widgets = ["keypress", "search_match", "url", "scroll", "progress"]

c.url.auto_search = 'naive'

# Unbind existing movement keys
config.unbind("h")
config.unbind("j")
config.unbind("k")
config.unbind("l")

# Rebind to new movement keys
config.bind("j", "scroll left")
config.bind("k", "scroll down")
config.bind("l", "scroll up")
config.bind(";", "scroll right")

# Unbind existing keys for navigation
config.unbind("H")
config.unbind("L")
config.unbind("J")
config.unbind("K")

config.bind("K", "scroll-page 0 0.5")  # Instead of "C-d"
config.bind("L", "scroll-page 0 -0.5")  # Instead of "C-i"

# Rebind with new layout
config.bind("<Alt-o>", "back")  # Instead of "H"
config.bind("<Alt-i>", "forward")  # Instead of "L"
config.bind("<Alt-.>", "tab-next")  # Instead of "J"
config.bind("<Alt-,>", "tab-prev")  # Instead of "K"

# Remap command input to ','
config.bind(',', 'cmd-set-text :')

# Carot mod keys
config.unbind("h", mode="caret")
config.unbind("j", mode="caret")
config.unbind("k", mode="caret")
config.unbind("l", mode="caret")

config.bind("j", "move-to-prev-char", mode="caret")
config.bind("k", "move-to-next-line", mode="caret")
config.bind("l", "move-to-prev-line", mode="caret")
config.bind(";", "move-to-next-char", mode="caret")


# Bind Alt+c to copy selected text in normal and caret modes
config.bind("<Alt-c>", "fake-key <Ctrl+c>", mode="normal")
config.bind("<Alt-c>", "fake-key <Ctrl+c>", mode="caret")

# Bind Alt+v to paste clipboard content in normal, and insert modes
config.bind("<Alt-v>", "fake-key <Ctrl+v>", mode="insert")
config.bind("<Alt-v>", "fake-key <Ctrl+v>", mode="normal")

# Bind Alt+Backspace to delete previous word
config.bind("<Alt-w>", "fake-key <Ctrl-Backspace>", mode="insert")

# Bind Alt+q to return to normal mode in insert, passthrough and caret mode
config.bind("<Alt-q>", "mode-enter normal", mode="insert")
config.bind("<Alt-q>", "mode-enter normal", mode="caret")
config.bind("<Alt-q>", "mode-enter normal", mode="passthrough")

# Bind Alt+Delete to delete next word
config.bind("<Alt-d>", "fake-key <Ctrl-Delete>", mode="insert")
