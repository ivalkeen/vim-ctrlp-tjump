command! CtrlPtjump call ctrlp#tjump#exec('n')
command! -range CtrlPtjumpVisual <line1>,<line2>call ctrlp#tjump#exec('v')
