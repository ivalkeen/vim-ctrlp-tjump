if (exists('g:loaded_ctrlp_tjump') && g:loaded_ctrlp_tjump)
      \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_tjump = 1

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

function! ctrlp#tjump#exec(mode)
  if a:mode == 'v'
    let s:word = s:get_visual_selection()
  else
    if (&filetype == 'ruby' || &filetype == 'eruby') && exists("*RubyCursorIdentifier")
      let s:word = RubyCursorIdentifier()
    else
      let s:word = expand('<cword>')
    endif
  endif

  let s:taglist = taglist('^'.s:word.'$')
  let s:bname = fnamemodify(bufname('%'), ':p')

  if len(s:taglist) == 0
    echo("No tags found for: ".s:word)
  elseif len(s:taglist) == 1
    call feedkeys(":tag ".s:word."\r", 'nt')
  else
    call ctrlp#init(ctrlp#tjump#id())
  endif
endfunction

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#tjump#init()
  let input = map(s:order_tags(), 'v:key + 1 . "\t" . v:val["kind"] . "\t" . v:val["name"] . "\t" . v:val["filename"] . "\t" . v:val["cmd"]')

  if !ctrlp#nosy()
    cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    sy match CtrlPTabExtra `^\(.\{-}\t\)\{3}`
    sy match CtrlPTabExtra `\(.*\t\)\@<=/.*/$`
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
  call s:open_tag(a:str)
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

function! s:open_tag(str)
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
  exec ":".idx."tag ".s:word
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

" Put tags of current buffer first. Otherwise, taglist's order doesn't match
" tselect's order
function! s:order_tags()
  let tgs = copy(s:taglist)
  let [ctgs, otgs] = [[], []]

  for tgi in tgs
    let lst = s:bname == fnamemodify(tgi["filename"], ':p') ? 'ctgs' : 'otgs'
    call call('add', [{lst}, tgi])
  endfo

  return ctgs + otgs
endfunction
