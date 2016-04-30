command! -nargs=? CtrlPtjump call ctrlp#tjump#exec('n', <f-args>)
command! -range CtrlPtjumpVisual <line1>,<line2>call ctrlp#tjump#exec('v')
