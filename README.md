# CtrlP tjump

CtrlP extension for fuzzy-search in tag matches.
May be used instead of `:tjump` or `:tselect` for IDE-like `Goto declaration` functionality,
which jumps to the declaration in case of one match, and shows quick-search window in case of multiple matches.

Two vim commands are created by this plugin:

* `CtrlPtjump` - go to declaration of the identifier under cursor
* `CtrlPtjumpVisual` - go to declaration of the visual selected text

![CtrlP tjump][1]

## Prerequisites

1. [CtrlP][2] should be installed
2. Tags should already work with `:tag`, `:tselect` and `:tjump` commands.

## Installation

1.  Use your favorite method (I prefer [Vundle][3])
2. (Optional) Create mapping

    ```
    nnoremap <c-]> :CtrlPtjump<cr>
    vnoremap <c-]> :CtrlPtjumpVisual<cr>
    ```

## Basic Usage

1. Move cursor to the Class/Method usage in your code
2. Press `c-]` (if you have created mapping) or just execute `:CtrlPtjump`
(or `:CtrlPtjumpVisual` in visual mode) in the command line.

## Configuration

It is possible to configure shortener for filenames, that will be displayed in
CtrlP window. In the example below, RegExp `'/home/.*/gems/'` will be
substituted by string `'.../'`. This may be useful if filename (with path) of
generated tag is long and you want to make it shorter.

    let g:ctrlp_tjump_shortener = ['/home/.*/gems/', '.../']

If there is only one tag found, it is possible to open it without opening CtrlP
window:

    let g:ctrlp_tjump_only_silent = 1

[1]: http://i.imgur.com/1UrMOpd.png
[2]: https://github.com/kien/ctrlp.vim
[3]: https://github.com/gmarik/vundle
