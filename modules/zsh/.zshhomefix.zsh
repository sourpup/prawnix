
# Since we set ZDOTDIR at the system level
# we need to override where zsh should read/write its history
export HISTFILE=~/.zsh_history
# same with the comp file
# 
# from the manpage:
# To speed up the running of compinit, it can be made to produce a dumped 
# configuration that will be read in on future invocations; this is the 
# default, but can be turned off by calling compinit with the option -D.  The 
# dumped file is .zcompdump in the same directory as the startup files (i.e. 
# $ZDOTDIR or $HOME); alternatively, an explicit file name can be given by 
# `compinit -d dumpfile'.  The next invocation of compinit will read the 
# dumped file instead of performing a full initialization.
compinit -d ~/.zcompdump
