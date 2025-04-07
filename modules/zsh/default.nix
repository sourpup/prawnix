# zsh with z4humans baked in
{ pkgs, ... }:

let

  ##  .zshrc extensions
  ## these all get concatonated together to form the systems
  ## .zshrc
  zsh_rc_parts = [
    ./.zshrc # main zshrc

    (pkgs.writeTextFile {
      name = "zsh_home_fix";
      text = ''
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
      '';
    })

    (pkgs.writeTextFile {
      name = "zsh_aliases";
      text = ''
        s () {
            /usr/bin/ssh "$@"
        }
        sx () {
            /usr/bin/ssh -X "$@"
        }

        fd () {
            find . -name "*$@*"
        }

        la () {
            ls --color -lah "$@"
        }
      '';
    })

    (pkgs.writeTextFile {
      name = "z4h_auto_tele_hosts";
      text = ''
        # The default value if none of the overrides above match the hostname.
        zstyle ':z4h:ssh:*'                   enable 'no'
        zstyle ':z4h:ssh:liquidsnake-*'                   enable 'yes'
        zstyle ':z4h:ssh:raiden'                   enable 'yes'
        zstyle ':z4h:ssh:mistral'                   enable 'yes'
        zstyle ':z4h:ssh:solidsnake'                   enable 'yes'
      '';
    })


    (pkgs.writeTextFile {
      name = "zsh_work_loader";
      text = ''
        # Load work profile do this last so we can reload p10k if we want to
        if [ -f "$HOME/.zshwork" ]; then . "$HOME/.zshwork"; fi
      '';
    })

  ];

in

{
  imports =
    [
      # none
    ];


  # this file sets simply sets ZDOTDIR=/etc/zsh, which tells zsh
  # to look in /etc/zsh for all of the things it would usually find
  # in $HOME
  # the end of the standard nixos /etc/zshenv sources it for us
  environment.etc = {
    "zshenv.local".source = ./zshenv.local;
  };

  # install our zsh config files with modifications
  environment.etc = {
    "zsh/.zshrc".source = (
      pkgs.concatTextFile {
        name = ".zshrc";
        files = zsh_rc_parts;
      });
  };

  environment.etc = {
    "zsh/.zshenv".source = ./.zshenv;
  };
  environment.etc = {
    "zsh/.p10k.zsh".source = ./.p10k.zsh;
  };

  # TODO explicitly install zsh4humans cache
  # right now when launching zsh for the first time, it will
  # download z4h things to ~/.cache
  # instead, take the zsh4humans bundle and package it so we
  # and have it installed in /etc/zsh/<blah> for us
  # so the download doesn't have to happen at first launch
  # the location it loads from is configured in ~/.zshenv


  # setup default shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 100000;
  };
  # set zsh as the default shell
  users.defaultUserShell = pkgs.zsh;
  # ensure the user still shows up in GDM: https://nixos.wiki/wiki/Zsh
  environment.shells = with pkgs; [ zsh ];
}
