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

  let s:ignorecase_save = &ignorecase
  set noignorecase
  let s:taglist = taglist('^'.s:word.'$')
  let s:bname = fnamemodify(bufname('%'), ':p')

  if len(s:taglist) == 0
    echo("No tags found for: ".s:word)
  elseif len(s:taglist) == 1 && g:ctrlp_tjump_only_silent == 1
    exe "silent! tag ".s:word
    let &ignorecase = s:ignorecase_save
  else
    call ctrlp#init(ctrlp#tjump#id())
  endif
endfunction

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#tjump#init()
  let input = map(s:order_tags(), 'v:key + 1 . "\t" . v:val["kind"] . "\t" . (g:ctrlp_tjump_skip_tag_name ? "" : v:val["name"] . "\t") . s:short_filename(v:val["filename"]) . "\t" . v:val["cmd"]')
  " let input = map(s:taglist, 'v:key + 1 . "\t" . v:val["kind"] . "\t" . (g:ctrlp_tjump_skip_tag_name ? "" : v:val["name"] . "\t") . s:short_filename(v:val["filename"]) . "\t" . v:val["cmd"]')

  if !ctrlp#nosy()
    cal ctrlp#hicheck('CtrlPTabExtra', 'Comment')

    if g:ctrlp_tjump_skip_tag_name
      sy match CtrlPTabExtra `^\(.\{-}\t\)\{2}`
    else
      sy match CtrlPTabExtra `^\(.\{-}\t\)\{3}`
    endif

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
  call s:open_tag(a:str, a:mode)
  let &ignorecase = s:ignorecase_save
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

" Shorten file name
function! s:short_filename(filename)
  if exists('g:ctrlp_tjump_shortener')
    let short_filename = substitute(a:filename, g:ctrlp_tjump_shortener[0], g:ctrlp_tjump_shortener[1], 'g')
  else
    let short_filename = a:filename
  end
  return short_filename
endfunction
