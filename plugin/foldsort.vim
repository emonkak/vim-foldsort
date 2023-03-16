if exists('g:loaded_foldsort')
  finish
endif

command! -nargs=? -range=% -bar -bang FoldSort
\ <line1>,<line2>call foldsort#sort_folds(<q-args>, <bang>0)

command! -range=% -bar FoldShuffle
\ <line1>,<line2>call foldsort#shuffle_folds()

let g:loaded_foldsort = 1
