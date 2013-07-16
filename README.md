# CtrlP tjump

CtrlP extension for fuzzy-search in tag matches.
May be used instead of `:tjump` or `:tselect` for IDE-like `Goto declaration` functionality,
which jumps to the declaration in case of one match, and shows quick-search window in case of multiple matches.

![CtrlP tjump][1]

## Prerequisites

1. [CtrlP][2] should be installed
2. Tags should already work with `:tag`, `:tselect` and `:tjump` commands.

## Installation

1.  Use your favorite method (I prefer [Vundle][3])
2. (Optional) Create mapping

    ```
    nnoremap <c-]> :CtrlPtjump<cr>
    ```

    *Note for Ruby users*: to support identifiers with ! and ? in the end, consider
    adding one more mapping to your .vimrc

    ```
    autocmd FileType ruby,eruby nnoremap <silent> <buffer> <C-]> :call ctrlp#tjump#exec(RubyCursorIdentifier())<CR>
    ```

    This requires vim-ruby plugin to be installed

## Basic Usage

1. Move cursor to the Class/Method usage in your code
2. Press `c-]` (if you have created mapping) or just execute `:CtrlPtjump` in the command line.

[1]: http://i.imgur.com/1UrMOpd.png
[2]: https://github.com/kien/ctrlp.vim
[3]: https://github.com/gmarik/vundle

## TODO

1. Support visual mode (with region selection)
