if (exists('g:loaded_ctrlp_tjump') && g:loaded_ctrlp_tjump)
      \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_tjump = 1

"
" configuration options

" replace expression with pattern in filenames' list
" let g:ctrlp_tjump_shortener = ['scp://.*gems/', '.../']

" Skip selection window if only one match found
if !exists('g:ctrlp_tjump_only_silent') | let g:ctrlp_tjump_only_silent = 0 | en

" Skip tag name in list
if !exists('g:ctrlp_tjump_skip_tag_name') | let g:ctrlp_tjump_skip_tag_name = 0 | en

call add(g:ctrlp_ext_vars, {
      \ 'init': 'ctrlp#tjump#init()',
      \ 'accept': 'ctrlp#tjump#accept',
      \ 'lname': 'tjump',
      \ 'sname': 'tjump',
      \ 'type': 'line',
      \ 'enter': 'ctrlp#tjump#enter()',
      \ 'exit': 'ctrlp#tjump#exit()',
      \ 'opts': 'ctrlp#tjump#opts()',
      \ 'sort': 0,
      \ 'specinput': 0,
      \ })

function! ctrlp#tjump#exec(mode, ...)
  if a:mode == 'v'
    let s:word = s:get_visual_selection()
  else
    if exists('a:1')
      let s:word = a:1
    else
      if (&filetype == 'ruby' || &filetype == 'eruby') && exists("*RubyCursorIdentifier")
        let s:word = RubyCursorIdentifier()
      else
        let s:word = expand('<cword>')
      endif
    en
  endif

  let s:taglist = taglist('^'.s:word.'$')
  let s:bname = fnamemodify(bufname('%'), ':p')

  if len(s:taglist) == 0
    echo("No tags found for: ".s:word)
  elseif len(s:taglist) == 1 && g:ctrlp_tjump_only_silent == 1
    call feedkeys(":silent! tag ".s:word."\r", 'nt')
  else
    call ctrlp#init(ctrlp#tjump#id())
  endif
endfunction

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#tjump#init()
  let tgs = s:order_tags()
  let max_short_filename = s:maxlen(tgs, 'short_filename') + 1
  let input = map(tgs, '
        \ s:align_left(v:key + 1, 3) . "\t" .
        \ v:val["pri"] . "\t" .
        \ v:val["kind"] . "\t" . 
        \ (g:ctrlp_tjump_skip_tag_name ? "" : v:val["name"] . "\t") .
        \ s:align_right(v:val["short_filename"], max_short_filename)."\t".
        \ v:val["short_cmd"]
        \ ')

  if !ctrlp#nosy()
    cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')

    if g:ctrlp_tjump_skip_tag_name
      sy match CtrlPTabExtra `\(.\{-}\t\)\{3}`
    else
      sy match CtrlPTabExtra `\(.\{-}\t\)\{4}`
    endif

    sy match CtrlPTabExtra `.\{-}\t\zs.*\ze`
  en
  return input
endfunction

" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#tjump#accept(mode, str)
  " For this example, just exit ctrlp and run help
  call ctrlp#exit()
  call s:open_tag(a:str, a:mode)
endfunction

" (optional) Do something before enterting ctrlp
function! ctrlp#tjump#enter()
endfunction

" (optional) Do something after exiting ctrlp
function! ctrlp#tjump#exit()
endfunction

" (optional) Set or check for user options specific to this extension
function! ctrlp#tjump#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#tjump#id()
  return s:id
endfunction

function! s:open_tag(str, mode)
  " If 'cscopetag' is set, the 'tag' command will actually use the 'cstag'
  " command which in turn performs a 'tjump'. Since 'tjump' doesn't support
  " ranges, if there is more than one match, the default tags menu is
  " displayed. To work around this, we temporarily disable using 'cstag',
  " however, in order to restore the option after a selection has been made we
  " have to use 'exec' instead of 'feedkeys', otherwise the script will exit
  " with the options restored before the 'tag' command is actually run.
  let cstopt = &cst
  set nocst
  let idx = split(a:str, '\t')[0]
  if a:mode == 'e'
    exec ":silent! ".idx."tag ".s:word
  elseif a:mode == 't'
    exec ":silent! tab ".idx."tag ".s:word
  elseif a:mode == 'v'
    exec ":silent! vertical ".idx."stag ".s:word
  elseif a:mode == 'h'
    exec ":silent! ".idx."stag ".s:word
  end
  let &cst = cstopt
endfunction

function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

" Order must match tselect's order (see :help tag-priority)
function! s:order_tags()
  let [FSC, F_C, F__, FS_, _SC, __C, ___, _S_] = [[], [], [], [], [], [], [], []]

  for tgi in s:taglist
    let priority = s:priority(tgi)
    let lst = substitute(priority, ' ', '_', 'g')
    let tgi['pri'] = priority
    let tgi['short_cmd'] = s:short_cmd(tgi)
    let tgi['short_filename'] = s:short_filename(tgi['filename'])
    call call('add', [{lst}, tgi])
  endfo

  return FSC + F_C + F__ + FS_ + _SC + __C + ___ + _S_
endfunction

function! s:align_left(str, width)
  let pad = a:width - strlen(a:str)
  return repeat(' ', pad).a:str
endfunction

function! s:align_right(str, width)
  let pad = a:width - strlen(a:str)
  return a:str.repeat(' ', pad)
endfunction

function! s:maxlen(tgs, key)
  let max = 0
  for tgi in a:tgs
    let len = strlen(tgi[a:key])
    if len > max
      let max = len
    endif
  endfo
  return max
endfunction

" Return the FSC priority string of a tag, see :help tag-priority
function! s:priority(tgi)
  let c_full_match = s:word ==# a:tgi['name'] ? 'F' : ' '
  let c_static_tag = 1 == a:tgi['static'] ? 'S' : ' '
  let c_current_file = s:bname == fnamemodify(a:tgi['filename'], ':p') ? 'C' : ' '
  let priority = c_full_match.c_static_tag.c_current_file
  return priority
endfunction

" Extract the trimmed cmd string between prefix and suffix
" Valid tag cmd prefixes: /^ | ?^ | / | ?
" Valid tag cmd suffixes: $/ | $? | / | ?
function! s:short_cmd(tgi)
  let short_cmd = substitute(a:tgi['cmd'], '\v^(/\^|\?\^|/|\?)?\s*(.{-})\s*(\$/|\$\?|/|\?)?$', '\2', '')
  return short_cmd
endfunction

" Shorten file name
function! s:short_filename(filename)
  if exists('g:ctrlp_tjump_shortener')
    let short_filename = substitute(a:filename, g:ctrlp_tjump_shortener[0], g:ctrlp_tjump_shortener[1], 'g')
  else
    let short_filename = a:filename
  end
  return short_filename
endfunction

" vim:sw=2:ts=2:et
