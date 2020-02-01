{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager =
    { enable = true;
    };

  programs.fish =
    { enable = true;
    };

  xsession.windowManager.xmonad = 
    { enable                 = true;
      enableContribAndExtras = true;
      config = pkgs.writeText "xmonad.hs" ''
        {-# LANGUAGE FlexibleContexts #-}
        {-# PatternGuards #-}
        {-# ExplicitForAll #-}
        {-# RankNTypes #-}
        {-# ScopedTypeVariables #-}
        {-# LANGUAGE DeriveDataTypeable #-}

        import Control.Applicative ((<$>),(<*>))
        import XMonad
        import XMonad.Actions.WindowBringer
        import XMonad.Hooks.FadeWindows
        import XMonad.Util.Font
        import XMonad.Hooks.ManageHelpers
        import XMonad.Layout.Grid
        import XMonad.Layout.NoBorders
        import XMonad.Layout.Tabbed
        import XMonad.Util.Loggers
        import Control.Monad.IO.Class
        import qualified XMonad.Hooks.EwmhDesktops as EWMH
        import qualified XMonad.StackSet as SS
        import qualified XMonad.Util.ExtensibleState as XS
        import qualified XMonad.Util.EZConfig as EZ

        {-import XMonad.Actions.WorkspaceBacklight-}

        modmask = mod4Mask

        -- default applications
        webbrowser = "google-chrome-stable"

        -- remove the ncmpcpp toggle command as it's currently broken
        toggleSound = "amixer set Master toggle"
        term = "termite"
        pdfviewer = "zathura"

        -- use amixer or pactl?
        data VolControl = Amixer | Pactl deriving (Eq, Ord, Show)

        volControl = Pactl

        volUp = 
          case volControl of
            Amixer -> "amixer set Master 5%+"
            Pactl -> "pactl set-sink-volume @DEFAULT_SINK@ +5%"

        volDown = 
          case volControl of
            Amixer -> "amixer set Master 5%-"
            Pactl -> "pactl set-sink-volume @DEFAULT_SINK@ -5%"

        volToggle = 
          case volControl of 
            Amixer -> "amixer set Master toggle"
            Pactl -> "pactl set-sink-mute @DEFAULT_SINK@ toggle"

        bckLightDown = "xbacklight -dec 5"
        bckLightUp = "xbacklight -inc 5"

        -- custom keyboard mappings
        customkeys :: [(String,X ())]
        customkeys =
          [ ("M-v",                      spawn volUp)
          , ("M-S-v"                   , spawn volDown)
          , ("M-a"                     , spawn volToggle)
          , ("M-c"                     , spawn webbrowser)
          , ("M-t"                     , spawn term)
          , ("M-S-t"                   , withFocused $ windows . SS.sink)
          , ("M-z"                     , spawn pdfviewer)
          , ("<XF86MonBrightnessUp>"   , spawn bckLightUp)
          , ("<XF86MonBrightnessDown>" , spawn bckLightDown)
          , ("<XF86AudioRaiseVolume>"  , spawn volUp)
          , ("<XF86AudioLowerVolume>"  , spawn volDown)
          , ("<XF86AudioMute>"         , spawn volToggle)
          ]

        -- border colors
        focusBorder = "#a0a0a0"
        unfocusBorder = "#303030"

        -- default Tall config 
        tiled = Tall 
          { tallNMaster = nm
          , tallRatioIncrement = inc
          , tallRatio = rt
          }
          where 
            nm = 1
            inc = 3/100
            rt = 1/2

        -- tabbed layout config
        myTabbed = tabbedBottom shrinkText tabCfg
          where tabCfg = def

        -- layouts
        layouts = myTabbed
          ||| tiled
          ||| Grid
          ||| Full

        -- layout hooks 
        myLayoutHooks = 
            smartBorders
          $ layouts

        -- hooks to perform when a window opens
        myManageHooks = helpers <+> manageHook def

        helpers = composeOne
          [ isFullscreen -?> doFullFloat --make fullscreen windows (as when watching a video) floating instead of tiled
          , isDialog     -?> doCenterFloat
          ]

        -- X event hooks
        myEventHooks = 
          EWMH.fullscreenEventHook
          <+> (handleEventHook def)


        -- myXmobar = statusBar myXmobarCmd myXmobarPP toggleStrutsKey
        --   where
        --     myXmobarCmd = "xmobar -o ./xmobarcc"
        --     myXmobarPP = xmobarPP 
        --                   { ppCurrent = xmobarColor "#859900" "" . wrap "[" "]"
        --                   , ppVisible = xmobarColor "#2aa198" "" . wrap "(" ")"
        --                   , ppLayout = xmobarColor "#2aa198" ""
        --                   , ppTitle = xmobarColor "#859900" "" . shorten 50
        --                   }
        --     toggleStrutsKey XConfig{modMask = modm} = (modm, xK_b)

        main = xmonad config
          where
            config = def 
              { manageHook = myManageHooks
              , handleEventHook = myEventHooks
              , layoutHook = myLayoutHooks
              , modMask = modmask
              , terminal = "xterm"
              , normalBorderColor = unfocusBorder
              , focusedBorderColor = focusBorder
              }
              `EZ.additionalKeysP` customkeys

      '';

    };
  
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "19.09";

  programs.git =
  { enable = true;
    aliases = 
      { co   = "checkout";
        cm   = "checkout master";
        b    = "branch";
        rb   = "rebase";
        rbi  = "rebase -i";
        lgga = "log --graph --decorate --oneline --all";
        st   = "status";
      };
  }; 

  programs.neovim = 
  { enable  = true;
    plugins = with pkgs.vimPlugins;
      [ fugitive
        easy-align
      ];
    extraConfig = ''
      let g:netrw_banner=0        " disable annoying banner
      let g:netrw_browse_split=0  " horizontally split window
      " let g:netrw_altv=1          " open splits to the right
      let g:netrw_winsize=90
      let g:netrw_liststyle=3     " tree view
      let g:netrw_list_hide=netrw_gitignore#Hide()
      let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'

      "EasyAlign
      let g:easy_align_delimiters = { '?': { 'pattern': '?' }, '(': { 'pattern': '(' } }

      " start EasyAlign (visual)
      xmap ga <Plug>(EasyAlign)
      " start EasyAlign (normal)
      nmap ga <Plug>(EasyAlign)

      " Per default, netrw leaves unmodified buffers open. This autocommand
      " deletes netrw's buffer once it's hidden (using ':q', for example)
      autocmd FileType netrw setl bufhidden=delete

      " I like syntax highlighting
      syntax enable

      " set custom colors
      "use 16 colors
      set t_Co=16 
      set background=dark
      colorscheme elflord

      " show the commands as I type them
      set showcmd

      " don't wrap text by default
      set nowrap

      " allow for inline searching
      set incsearch

      " fold code by syntax
      set foldmethod=syntax

      " default tab size
      set tabstop=2
      " spaces to use for auto-indent
      set shiftwidth=2
      " number of spaces for a single tab
      set softtabstop=2
      set expandtab

      " show lines numbers
      set number
      set relativenumber

      " turn off smart indenting
      set nosmartindent

      " turn off spell check
      set nospell

      " set the program to use for the S-K mapping
      set keywordprg=

      " set the number of lines to buffer the cursor with (above or below) when
      " scrolling
      set scrolloff=10

      " highlight when I've gone past the 80 character width
      " ctermbg=lightgrey
      highlight ColorColumn cterm=reverse ctermbg=none
      call matchadd('ColorColumn', '\%81v', 30)

      " set map leader for custom key-maps
      let mapleader = "," 

      " printer options
      set printoptions=top:1in,bottom:1in,left:0.5in,right:0.5in
      set printheader=" "

      set wildignore+=*.o
      set wildignore+=*.lib
      set wildignore+=*/node_modules/*
      set wildignore+=tags
      set wildignore+=result
      set wildignore+=*.dyn_*
      set wildignore+=*.hi
      set wildignore+=*.so
      set wildignore+=*.a
      set wildignore+=*/dist-newtyle/*
      set wildignore+=*/dist/*

      " custom mappings

      " open quickfix window
      nmap <leader>co :copen<cr><C-w><S-j>
      " center line on screen
      nmap <space> zz
      " make
      nmap <leader>m :make<cr>
      " vertical split
      nmap <leader>vs :vsp<CR>
      " horizontal split
      nmap <leader>hs :sp<CR>
      " write
      nmap <leader>w :w<cr>
      " open this file for editing
      nmap <leader>se :tabnew ~/.config/nvim/init.vim<cr>
      " open help in new tab
      nmap <leader>hh :tab help 
      " open new tab
      nmap <leader>tn :tabnew<cr>
      " close tab
      nmap <leader>td :tabclose<cr>
      " quit
      nmap <leader>q :q<cr>
      " next buffer
      nmap <leader>bn :bn<cr>
      " previous buffer
      nmap <leader>bp :bp<cr>
      " close buffer
      nmap <leader>bd :bd<cr>
      " switch to a presentation friend mode
      nmap <leader>prez :so ~/.config/nvim/prez.vim<cr>
      " clear search highlight
      nmap <leader>no :nohlsearch<cr>
      " git add
      nmap <leader>ga :Gwrite<cr>
      " git commit
      nmap <leader>gc :Gcommit<cr>
      " git status
      nmap <leader>gs :Gstatus<cr>
      " git vetical diff
      nmap <leader>gd :Gvdiff<cr>
      " open netrw
      nmap <leader>nw :Netrw<cr>
      " javascript class snippet
      nnoremap <leader>class :-1read $HOME/.config/nvim/snippets/js/newJsClass.js<cr>
      " javascript model
      nnoremap <leader>jsmodel :-1read $HOME/.config/nvim/snippets/js/expressModel.js<cr>:%s/X/
      " haskell LANGUAGE pragma
      nnoremap <leader>lang :-1read $HOME/.config/nvim/snippets/haskell/language.hs<cr>2f<space>
      nnoremap <leader>module :-1read $HOME/.config/nvim/snippets/haskell/module.hs<cr>2f<space>
      " merge multiple commit messages in a squash to a bulletted list
      nnoremap <leader>gm :%s/^\s\{-}\n\{-}#.*\n\{-}\s\{-}\n//g<cr>:%s/\n\n/\r/g<cr>{j<C-v>]]I* <Esc>
      " hoogle the current word
      noremap <leader>hg :!hoogle <C-R><C-W><cr>
      " vim grep current word
      noremap <leader>vg :vimgrep /\<<C-R><C-W>\>/ ./**<cr>
      " set keymap to haskell
      noremap <leader>kh :set keymap=haskell
      noremap <leader>kp :set keymap=pollen
      " replace currently highlighted text block with regex
      vmap <leader>s y:%s/<C-r>"/
      nmap <leader>s, :s/, \{-}/\r,/g
      nmap <leader>me :read !grep "const .*=" %<cr>vap :s/^const \(.\{-}\) =.*$/, \1/g<cr>o}<ESC>{jr{
      '';
  };
}
