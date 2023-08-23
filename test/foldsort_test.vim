let g:foldsort_debug = 1

silent runtime! plugin/foldsort.vim

function! s:test_nested_folds() abort
  let source = [
  \   'B {{{1',
  \   'B.B {{{2',
  \   'B.B.1',
  \   'B.B.2',
  \   'B.A {{{2',
  \   'B.A.1',
  \   'A {{{1',
  \   'A.B {{{2',
  \   'A.B.1',
  \   'A.B.2',
  \   'A.A {{{2',
  \   'A.A.1',
  \   'A.C {{{2',
  \   'A.C.1',
  \   'A.C.2',
  \   'A.C.3',
  \   'C {{{1',
  \   'C.1',
  \ ]

  " Sort between A and A
  call s:prepare_buffer(source)
  %FoldSort
  call assert_equal([
  \   'A {{{1',
  \   'A.B {{{2',
  \   'A.B.1',
  \   'A.B.2',
  \   'A.A {{{2',
  \   'A.A.1',
  \   'A.C {{{2',
  \   'A.C.1',
  \   'A.C.2',
  \   'A.C.3',
  \   'B {{{1',
  \   'B.B {{{2',
  \   'B.B.1',
  \   'B.B.2',
  \   'B.A {{{2',
  \   'B.A.1',
  \   'C {{{1',
  \   'C.1',
  \ ], getline(1, line('$')))
  call assert_equal(1, foldclosed(1))
  call assert_equal(11, foldclosed(11))

  " Sort between A.A and A.C
  call s:prepare_buffer(source)
  7foldopen
  8,16FoldSort
  call assert_equal([
  \   'B {{{1',
  \   'B.B {{{2',
  \   'B.B.1',
  \   'B.B.2',
  \   'B.A {{{2',
  \   'B.A.1',
  \   'A {{{1',
  \   'A.A {{{2',
  \   'A.A.1',
  \   'A.B {{{2',
  \   'A.B.1',
  \   'A.B.2',
  \   'A.C {{{2',
  \   'A.C.1',
  \   'A.C.2',
  \   'A.C.3',
  \   'C {{{1',
  \   'C.1',
  \ ], getline(1, line('$')))
  call assert_equal([1, 6], [foldclosed(1), foldclosedend(1)])
  call assert_equal(-1, foldclosed(7))
  call assert_equal([8, 9], [foldclosed(8), foldclosedend(8)])
  call assert_equal([10, 12], [foldclosed(10), foldclosedend(10)])
  call assert_equal([13, 16], [foldclosed(13), foldclosedend(13)])
  call assert_equal([17, 18], [foldclosed(17), foldclosedend(17)])

  " Sort between A.A and B.B
  call s:prepare_buffer(source)
  1foldopen
  7foldopen
  %FoldSort
  call assert_equal([
  \   'B {{{1',
  \   'A.A {{{2',
  \   'A.A.1',
  \   'A.B {{{2',
  \   'A.B.1',
  \   'A.B.2',
  \   'A {{{1',
  \   'A.C {{{2',
  \   'A.C.1',
  \   'A.C.2',
  \   'A.C.3',
  \   'B.A {{{2',
  \   'B.A.1',
  \   'B.B {{{2',
  \   'B.B.1',
  \   'B.B.2',
  \   'C {{{1',
  \   'C.1',
  \ ], getline(1, line('$')))
  call assert_equal(-1, foldclosed(1))
  call assert_equal([2, 3], [foldclosed(2), foldclosedend(2)])
  call assert_equal([4, 6], [foldclosed(4), foldclosedend(4)])
  call assert_equal(-1, foldclosed(7))
  call assert_equal([8, 11], [foldclosed(8), foldclosedend(8)])
  call assert_equal([12, 13], [foldclosed(12), foldclosedend(12)])
  call assert_equal([14, 16], [foldclosed(14), foldclosedend(14)])
  call assert_equal([17, 18], [foldclosed(17), foldclosedend(17)])

  bwipeout!
endfunction

function! s:test_pattern() abort
  let source = [
  \   'C {{{1',
  \   'C',
  \   '2 {{{1',
  \   'B',
  \   'D {{{1',
  \   'D',
  \   '1 {{{1',
  \   'A',
  \ ]

  call s:prepare_buffer(source)
  %FoldSort [AB]
  call assert_equal([
  \   'C {{{1',
  \   'C',
  \   '1 {{{1',
  \   'A',
  \   'D {{{1',
  \   'D',
  \   '2 {{{1',
  \   'B',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  call s:prepare_buffer(source)
  %FoldSort! [AB]
  call assert_equal([
  \   'C {{{1',
  \   'C',
  \   '2 {{{1',
  \   'B',
  \   'D {{{1',
  \   'D',
  \   '1 {{{1',
  \   'A',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  call s:prepare_buffer(source)
  %FoldSort [ABC]
  call assert_equal([
  \   '1 {{{1',
  \   'A',
  \   '2 {{{1',
  \   'B',
  \   'D {{{1',
  \   'D',
  \   'C {{{1',
  \   'C',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  call s:prepare_buffer(source)
  %FoldSort! [ABC]
  call assert_equal([
  \   'C {{{1',
  \   'C',
  \   '2 {{{1',
  \   'B',
  \   'D {{{1',
  \   'D',
  \   '1 {{{1',
  \   'A',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  call s:prepare_buffer(source)
  %FoldSort! [ABC]
  call assert_equal([
  \   'C {{{1',
  \   'C',
  \   '2 {{{1',
  \   'B',
  \   'D {{{1',
  \   'D',
  \   '1 {{{1',
  \   'A',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  bwipeout!
endfunction

function! s:test_permutations() abort
  let folds = [
  \   [
  \     'A {{{1',
  \     'A.1',
  \     'A.2',
  \     'A }}}',
  \   ],
  \   [
  \     'B {{{',
  \     'B.1',
  \     'B }}}',
  \   ],
  \   [
  \     'C {{{',
  \     'C }}}',
  \   ],
  \ ]
  let gaps = [
  \   ['1', '2', '3'],
  \   ['4', '5'],
  \   ['6'],
  \   [],
  \ ]

  for p_folds in s:permutations(folds)
    for p_gaps in s:permutations(gaps)
      let source = copy(p_gaps[0])
      let expected_lines = copy(p_gaps[0])
      let expected_reversed_lines = copy(p_gaps[0])

      for i in range(len(folds))
        call extend(source, p_folds[i])
        call extend(source, p_gaps[i + 1])
        call extend(expected_lines, folds[i])
        call extend(expected_lines, p_gaps[i + 1])
        call extend(expected_reversed_lines, folds[-(i + 1)])
        call extend(expected_reversed_lines, p_gaps[i + 1])
      endfor

      call s:prepare_buffer(source)
      %FoldSort
      call assert_equal(expected_lines, getline(1, line('$')))

      call s:prepare_buffer(source)
      %FoldSort!
      call assert_equal(expected_reversed_lines, getline(1, line('$')))
    endfor
  endfor

  bwipeout!
endfunction

function! s:test_sort_in_case_sensitive_order() abort
  let source = [
  \   'A {{{1',
  \   'A',
  \   'a {{{1',
  \   'a',
  \   'B {{{1',
  \   'B',
  \   'b {{{1',
  \   'b',
  \ ]

  call s:prepare_buffer(source)
  %FoldSort
  call assert_equal([
  \   'A {{{1',
  \   'A',
  \   'B {{{1',
  \   'B',
  \   'a {{{1',
  \   'a',
  \   'b {{{1',
  \   'b',
  \ ], getline(1, line('$')))
  call assert_equal([1, 2], [foldclosed(1), foldclosedend(1)])
  call assert_equal([3, 4], [foldclosed(3), foldclosedend(3)])
  call assert_equal([5, 6], [foldclosed(5), foldclosedend(5)])
  call assert_equal([7, 8], [foldclosed(7), foldclosedend(7)])

  bwipeout!
endfunction

function! s:test_unclosed_folds() abort
  let source = [
  \   'C {{{',
  \   'C }}}',
  \   'B {{{',
  \   'B }}}',
  \   'D {{{',
  \   'D }}}',
  \   'A {{{',
  \   'A',
  \ ]

  call s:prepare_buffer(source)
  %FoldSort
  call assert_equal([
  \   'A {{{',
  \   'A',
  \   'B {{{',
  \   'B }}}',
  \   'C {{{',
  \   'C }}}',
  \   'D {{{',
  \   'D }}}',
  \ ], getline(1, line('$')))
  call assert_equal([1, 8], [foldclosed(1), foldclosedend(1)])

  bwipeout!
endfunction

function! s:permutations(elements) abort
  let n = len(a:elements)
  let state = repeat([0], n)
  let results = [a:elements]
  let elements = copy(a:elements)

  let i = 1
  while i < n
    if state[i] < i
      if i % 2 == 0
        call s:swap(elements, 0, i)
      else
        call s:swap(elements, state[i], i)
      endif
      call add(results, copy(elements))
      let state[i] += 1
      let i = 1
    else
      let state[i] = 0
      let i += 1
    endif
  endwhile

  return results
endfunction

function! s:prepare_buffer(source) abort
  enew!
  setlocal foldmethod=marker
  call setline(1, a:source)
endfunction

function! s:swap(elements, i, j) abort
  let tmp = a:elements[a:i]
  let a:elements[a:i] = a:elements[a:j]
  let a:elements[a:j] = tmp
endfunction
