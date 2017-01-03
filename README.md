# vim-systemd-syntax

syntax highlighting and filetype detection for systemd unit files!

## Features

* Highlights known unit file directives and recognizeable values!
* Marks errors due to invalid or misspelled options/values!
* Over 80 hours of playtime!

## Installation

1. Set up [pathogen](https://github.com/tpope/vim-pathogen)
2. `git clone https://github.com/wgwoods/vim-systemd-syntax ~/.vim/bundle/`

Or just drop the two `.vim` files in `~/.vim/syntax` and `~/.vim/ftdetect`
manually. I'm sure you'll figure it out, you red-hot vim hacker you.

## History

I split this out of https://github.com/wgwoods/vim-scripts because it turns out
people were (re)packaging it separately?

## TODO

* Add missing directives?
  (I haven't updated this since 2011. Pull requests welcome!)
* Generate syntax from `/usr/lib/systemd/systemd --dump-config`
  so it's always up-to-date
    * Heck why doesn't [systemd] do that as part of its build?
* Contribute script to [systemd] that generates `syntax/systemd.vim` for us

[systemd]: https://github.com/systemd/systemd/

## License

Distributed under the same terms as `vim` itself.
