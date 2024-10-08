if !exists('g:foldsort_debug')
  let g:foldsort_debug = 0
endif

function! foldsort#shuffle_folds() abort range
  let folds = s:enumerate_folds(a:firstline, a:lastline)
  let fold_groups = s:group_folds(folds)
  for folds in fold_groups
    let shuffled_folds = s:shuffle(copy(folds))
    call s:arrange_folds(folds, shuffled_folds)
  endfor
endfunction

function! foldsort#sort_folds(pattern, is_reversed) abort range
  let folds = s:enumerate_folds(a:firstline, a:lastline)
  if a:pattern != ''
    let folds = s:filter_folds(folds, a:pattern)
  endif
  let fold_groups = s:group_folds(folds)
  let ComparerFn = a:is_reversed
  \              ? function('s:compare_folds_desc')
  \              : function('s:compare_folds_asc')
  for folds in fold_groups
    let sorted_folds = sort(copy(folds), ComparerFn)
    call s:arrange_folds(folds, sorted_folds)
  endfor
endfunction

function! s:arrange_folds(before_folds, after_folds) abort
  for fold in a:before_folds
    execute fold.start . ',' . fold.end . 'foldopen!'
  endfor

  setlocal nofoldenable

  try
    for i in range(len(a:before_folds))
      let before_fold = a:before_folds[i]
      let after_fold = a:after_folds[i]

      if before_fold is after_fold
        continue
      endif

      let j = after_fold.index
      let a:before_folds[i] = after_fold
      let a:before_folds[j] = before_fold
      let after_fold.index = i
      let before_fold.index = j

      let [ahead_fold, behind_fold] = s:swap_folds(before_fold, after_fold)

      " Recalculate positions between the ahead fold and the behind fold.
      if ahead_fold.index + 1 < behind_fold.index
        let offset = (ahead_fold.end - ahead_fold.start)
        \          - (behind_fold.end - behind_fold.start)

        for fold in a:before_folds[ahead_fold.index + 1:behind_fold.index - 1]
          let fold.start += offset
          let fold.end += offset
        endfor
      endif

      if g:foldsort_debug && !s:check_folds(a:before_folds)
        break
      endif
    endfor
  finally
    setlocal foldenable
  endtry

  for fold in a:after_folds
    " Some foldings may be invalid when it was rearranged, so we should ignore
    " errors.
    silent! execute fold.start . ',' . fold.end . 'foldclose'
  endfor
endfunction

function! s:check_folds(folds) abort
  let wrong_folds = []

  for fold in a:folds
    if fold.original_line !=# getline(fold.start)
      call add(wrong_folds, fold)
    endif
  endfor

  if len(wrong_folds) > 0
    echoerr 'Wrong folds are found: ' . string(wrong_folds)
    return 0
  endif

  return 1
endfunction

function! s:compare_folds_asc(x, y) abort
  if a:x.text <# a:y.text
    return -1
  endif
  if a:x.text ># a:y.text
    return 1
  endif
  return 0
endfunction

function! s:compare_folds_desc(x, y) abort
  if a:x.text ># a:y.text
    return -1
  endif
  if a:x.text <# a:y.text
    return 1
  endif
  return 0
endfunction

function! s:enumerate_folds(first_line, last_line) abort
  let folds = []
  let start = a:first_line

  while start <= a:last_line
    if foldclosed(start) > 0
      let end = foldclosedend(start)
      if end > 0
        let line = getline(start)
        call add(folds, {
        \   'start': start,
        \   'end': end,
        \   'level': foldlevel(start),
        \   'text': line,
        \   'original_line': line,
        \ })
        let start = end + 1
      else
        let start += 1
      endif
    else
      let start += 1
    endif
  endwhile

  return folds
endfunction

function! s:filter_folds(folds, pattern) abort
  let folds = []
  for fold in a:folds
    for lnum in range(fold.start, fold.end)
      let line = getline(lnum)
      let matched_text = matchstr(line, a:pattern)
      if matched_text != ''
        let fold.text = matched_text
        call add(folds, fold)
        break
      endif
    endfor
  endfor
  return folds
endfunction

function! s:group_folds(folds) abort
  let folds_by_level = {}

  for fold in a:folds
    let level = fold.level
    if has_key(folds_by_level, level)
      let folds = add(folds_by_level[level], fold)
      let fold.index = len(folds) - 1
    else
      let folds_by_level[level] = [fold]
      let fold.index = 0
    endif
  endfor

  return values(folds_by_level)
endfunction

function! s:shuffle(elements) abort
  let l = len(a:elements)
  while l > 0
    let i = rand() % l
    let l -= 1
    let tmp = a:elements[i]
    let a:elements[i] = a:elements[l]
    let a:elements[l] = tmp
  endwhile
  return a:elements
endfunction

function! s:sort_folds(folds, comparer) abort
  return sort(a:folds, a:comparer)
endfunction

function! s:swap_folds(first_fold, second_fold) abort
  if a:first_fold.start < a:second_fold.start
    let ahead_fold = a:first_fold
    let behind_fold = a:second_fold
  else
    let ahead_fold = a:second_fold
    let behind_fold = a:first_fold
  endif

  let [start1, end1, start2, end2] = s:swap_ranges(
  \   ahead_fold.start,
  \   ahead_fold.end,
  \   behind_fold.start,
  \   behind_fold.end
  \ )

  let ahead_fold.start = start2
  let ahead_fold.end = end2
  let behind_fold.start = start1
  let behind_fold.end = end1

  return [behind_fold, ahead_fold]
endfunction

function! s:swap_ranges(start_1, end_1, start_2, end_2) abort
  let reg_u = [@", getregtype('"')]
  let cursor = getcurpos()[1:]

  let lines_1 = a:end_1 - a:start_1
  let lines_2 = a:end_2 - a:start_2
  let new_end_1 = a:start_1 + lines_2
  let new_start_2 = a:start_2 + (lines_2 - lines_1)
  let new_end_2 = new_start_2 + lines_1

  try
    silent execute (a:start_2 . ',' . a:end_2 . 'delete') '"'
    silent execute (a:end_1 . 'put') '"'
    silent execute (a:start_1 . ',' . a:end_1 . 'delete') '"'
    silent execute ((new_start_2 - 1) . 'put') '"'
  finally
    call setreg('"', reg_u[0], reg_u[1])
    keepjump call cursor(cursor)
  endtry

  return [a:start_1, new_end_1, new_start_2, new_end_2]
endfunction
