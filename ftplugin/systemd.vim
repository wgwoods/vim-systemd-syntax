" Generally, buffer-local things for systemd files.

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

" Makes for easier commenting -- particularly with tools like
" tpope/vim-commentary that depend on this setting
set cms=#\ %s
