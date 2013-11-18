" foldsort - {abstract}
" Version: 0.0.0
" Copyright (C) 2013 emonkak <emonkak@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! foldsort#sort() range  "{{{2
  let original_winnr = winnr()
  let original_lazyredraw = &lazyredraw

  set lazyredraw
  split
  normal! zM

  try
    let currnet_lnum = foldclosed(a:firstline)
    let currnet_lnum = currnet_lnum > 0 ? currnet_lnum : a:firstline
    let last_lnum = a:lastline
    let folds_per_level = []

    while currnet_lnum < last_lnum
      if foldclosed(currnet_lnum) > 0
        let fold_level = foldlevel(currnet_lnum)
        let fold_end = foldclosedend(currnet_lnum)
        let i = len(folds_per_level)

        while i > fold_level
          call s:sort(remove(folds_per_level, -1))
          let i -= 1
        endwhile

        while i < fold_level
          call add(folds_per_level, [])
          let i += 1
        endwhile

        call add(folds_per_level[fold_level - 1], {
        \  "lnum1": currnet_lnum,
        \  "lnum2": fold_end,
        \  "line": getline(currnet_lnum)
        \ })

        execute currnet_lnum 'foldopen'
      endif

      let currnet_lnum += 1
    endwhile

    for folds in reverse(folds_per_level)
      call s:sort(folds)
    endfor
  finally
    close
    execute original_winnr 'wincmd w'
    let &lazyredraw = original_lazyredraw
  endtry
endfunction




" Misc.  "{{{1
function! s:compare(x, y)  "{{{2
  return a:x.line < a:y.line
endfunction




function! s:sort(xs)  "{{{2
  " Selection sort
  let xs = a:xs
  let i = 0
  let l = len(a:xs)

  while i < l
    let j = i + 1
    let min = i

    while j < l
      if s:compare(xs[j], xs[min])
        let min = j
      end

      let j += 1
    endwhile

    call s:swap(xs, i, min)

    let i += 1
  endwhile

  return xs
endfunction




function! s:swap(xs, i, j)  "{{{2
  if a:i == a:j
    return
  endif

  call s:swap_lines(a:xs[a:i].lnum1, a:xs[a:i].lnum2, a:xs[a:j].lnum1, a:xs[a:j].lnum2)

  let tmp_lnum1 = a:xs[a:i].lnum1
  let a:xs[a:i].lnum2 = a:xs[a:j].lnum1 + (a:xs[a:i].lnum2 - a:xs[a:i].lnum1)
  let a:xs[a:i].lnum1 = a:xs[a:j].lnum1
  let a:xs[a:j].lnum2 = tmp_lnum1 + (a:xs[a:j].lnum2 - a:xs[a:j].lnum1)
  let a:xs[a:j].lnum1 = tmp_lnum1

  let tmp = a:xs[a:i]
  let a:xs[a:i] = a:xs[a:j]
  let a:xs[a:j] = tmp

  let i = min([a:i + 1, a:j + 1])
  let l = min([max([a:i + 1, a:j + 1]), len(a:xs)])
  let diff = (a:xs[a:i].lnum2 - a:xs[a:i].lnum1) - (a:xs[a:j].lnum2 - a:xs[a:j].lnum1)

  while i < l
    let a:xs[i].lnum1 += diff
    let a:xs[i].lnum2 += diff
    let i += 1
  endwhile
endfunction




function! s:swap_lines(lnum1, lnum2, lnum3, lnum4)  "{{{2
  let reg_u = [@", getregtype('"')]

  " (1) Yank Fold-1
  " +-- Fold-1 (Yanked)  -----------------------------------------------------
  "
  " +-- Fold-2  --------------------------------------------------------------
  "
  " (2) Put to the bottom line of Fold-2
  " +-- Fold-1  --------------------------------------------------------------
  "
  " +-- Fold-2  --------------------------------------------------------------
  " +-- Fold-1 (Putted)  -----------------------------------------------------
  "
  " (3) Delete original Fold-2
  " +-- Fold-1  --------------------------------------------------------------
  "
  " +-- Fold-2 (Deleted)  ----------------------------------------------------
  " +-- Fold-1  --------------------------------------------------------------
  "
  " (4) Put to the bottom line of Fold-1
  " +-- Fold-1  --------------------------------------------------------------
  " +-- Fold-2 (Putted)  -----------------------------------------------------
  "
  " +-- Fold-1  --------------------------------------------------------------
  "
  " (5) Delete original Fold-1
  " +-- Fold-1 (Deleted)  ----------------------------------------------------
  " +-- Fold-2  --------------------------------------------------------------
  "
  " +-- Fold-1  --------------------------------------------------------------
  if a:lnum1 < a:lnum3
    silent execute printf('%d,%dyank "',   a:lnum1, a:lnum2)
    silent execute printf('%dput "',       a:lnum4)
    silent execute printf('%d,%ddelete "', a:lnum3, a:lnum4)
    silent execute printf('%dput "',       a:lnum2)
    silent execute printf('%d,%ddelete _', a:lnum1, a:lnum2)
  elseif a:lnum1 > a:lnum3
    silent execute printf('%d,%dyank "',   a:lnum3, a:lnum4)
    silent execute printf('%dput "',       a:lnum2)
    silent execute printf('%d,%ddelete "', a:lnum1, a:lnum2)
    silent execute printf('%dput "',       a:lnum4)
    silent execute printf('%d,%ddelete _', a:lnum3, a:lnum4)
  end

  call setreg('"', reg_u[0], reg_u[1])
endfunction




" __END__  "{{{1
" vim: foldmethod=marker
