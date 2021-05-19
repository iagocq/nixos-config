{ config, pkgs, lib, ... }:

{
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-nix ];
    settings = {
      relativenumber = true;
      number = true;
      smartcase = true;
    };
    extraConfig = ''
      set mouse=a
      if has("autocmd")
        autocmd FileType make set tabstop=8 shiftwidth=8 softtabstop=0 noexpandtab nosmarttab
      endif
      set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab
      filetype plugin indent on
      map <ESC>[1;[5D <C-Left>
      map <ESC>[1;[5C <C-Right>
      map! <ESC>[1;[5D <C-Left>
      map! <ESC>[1;[5C <C-Right>
      set clipboard=unnamedplus
      set ttymouse=sgr
      set hlsearch
      hi Visual ctermfg=None ctermbg=240 cterm=bold
      hi Search ctermfg=None ctermbg=240 cterm=bold
    '';
  };
}

