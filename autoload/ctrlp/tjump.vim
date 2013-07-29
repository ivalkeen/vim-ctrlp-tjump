if ( exists('g:loaded_ctrlp_tjump') && g:loaded_ctrlp_tjump )
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

function! ctrlp#tjump#exec(word)
  let s:word = a:word
  let taglist = taglist('^'.s:word.'$')

  if len(taglist) == 0
    echo("No tags found for: ".s:word)
  elseif len(taglist) == 1
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
  let input = map(taglist('^'.s:word.'$'), 'v:key + 1 . "\t" . v:val["kind"] . "\t" . v:val["name"] . "\t" . v:val["filename"] . "\t" . v:val["cmd"]')
  if !ctrlp#nosy()
    cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    sy match CtrlPTabExtra `^.*\t\(.*\t\)\@=`
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
  let [idx, kind, name, filename, cmd] = split(a:str, '\t')
  call feedkeys(":".idx."tag ".name."\r", 'nt')
endfunction
