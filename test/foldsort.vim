let g:foldsort#debug = 1

silent runtime! plugin/foldsort.vim

function! s:test_permutations() abort
  let folds = [
  \   [
  \     'A {{{',
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
      let expected_result = copy(p_gaps[0])
      let reversed_result = copy(p_gaps[0])
      for i in range(len(folds))
        call extend(source, p_folds[i])
        call extend(source, p_gaps[i + 1])
        call extend(expected_result, folds[i])
        call extend(expected_result, p_gaps[i + 1])
        call extend(reversed_result, folds[-(i + 1)])
        call extend(reversed_result, p_gaps[i + 1])
      endfor
      call s:do_test('%FoldSort', source, expected_result)
      call s:do_test('%FoldSort!', source, reversed_result)
    endfor
  endfor
endfunction

function! s:test_pattern() abort
  let source = [
  \   'C {{{',
  \   'C }}}',
  \   'B {{{',
  \   'B }}}',
  \   'D {{{',
  \   'D }}}',
  \   'A {{{',
  \   'A }}}',
  \ ]

  let expected = [
  \   'C {{{',
  \   'C }}}',
  \   'A {{{',
  \   'A }}}',
  \   'D {{{',
  \   'D }}}',
  \   'B {{{',
  \   'B }}}',
  \ ]
  call s:do_test('%FoldSort [AB]', source, expected)

  let expected = [
  \   'C {{{',
  \   'C }}}',
  \   'B {{{',
  \   'B }}}',
  \   'D {{{',
  \   'D }}}',
  \   'A {{{',
  \   'A }}}',
  \ ]
  call s:do_test('%FoldSort! [AB]', source, expected)

  let expected = [
  \   'A {{{',
  \   'A }}}',
  \   'B {{{',
  \   'B }}}',
  \   'D {{{',
  \   'D }}}',
  \   'C {{{',
  \   'C }}}',
  \ ]
  call s:do_test('%FoldSort [ABC]', source, expected)

  let expected = [
  \   'C {{{',
  \   'C }}}',
  \   'B {{{',
  \   'B }}}',
  \   'D {{{',
  \   'D }}}',
  \   'A {{{',
  \   'A }}}',
  \ ]
  call s:do_test('%FoldSort! [ABC]', source, expected)
endfunction

function! s:test_nested_folds() abort
  let source = [
  \   'B {{{',
  \   'B.1',
  \   'B.C {{{',
  \   'B.C.1',
  \   'B.C }}}',
  \   'B.2',
  \   'B.B {{{',
  \   'B.B.1',
  \   'B.B }}}',
  \   'B.3',
  \   'B.A {{{',
  \   'B.A.1',
  \   'B.A }}}',
  \   'B.4',
  \   'B }}}',
  \   '2',
  \   'D {{{',
  \   'D.1',
  \   'D }}}',
  \   '3',
  \   'A {{{',
  \   'A.1',
  \   'A.B {{{',
  \   'A.B.1',
  \   'A.B }}}',
  \   'A.2',
  \   'A.A {{{',
  \   'A.A.1',
  \   'A.A }}}',
  \   'A.3',
  \   'A.C {{{',
  \   'A.C.1',
  \   'A.C }}}',
  \   'A.4',
  \   'A }}}',
  \   '4',
  \   'C {{{',
  \   'C.1',
  \   'C }}}',
  \ ]
  let expected = [
  \   'B {{{',
  \   'B.1',
  \   'A.A {{{',
  \   'A.A.1',
  \   'A.A }}}',
  \   'B.2',
  \   'A.B {{{',
  \   'A.B.1',
  \   'A.B }}}',
  \   'B.3',
  \   'A.C {{{',
  \   'A.C.1',
  \   'A.C }}}',
  \   'B.4',
  \   'B }}}',
  \   '2',
  \   'C {{{',
  \   'C.1',
  \   'C }}}',
  \   '3',
  \   'A {{{',
  \   'A.1',
  \   'B.A {{{',
  \   'B.A.1',
  \   'B.A }}}',
  \   'A.2',
  \   'B.B {{{',
  \   'B.B.1',
  \   'B.B }}}',
  \   'A.3',
  \   'B.C {{{',
  \   'B.C.1',
  \   'B.C }}}',
  \   'A.4',
  \   'A }}}',
  \   '4',
  \   'D {{{',
  \   'D.1',
  \   'D }}}',
  \ ]

  call s:do_test('1foldopen | 21foldopen | %FoldSort', source, expected)

  let expected = [
  \   'B {{{',
  \   'B.1',
  \   'B.C {{{',
  \   'B.C.1',
  \   'B.C }}}',
  \   'B.2',
  \   'B.B {{{',
  \   'B.B.1',
  \   'B.B }}}',
  \   'B.3',
  \   'B.A {{{',
  \   'B.A.1',
  \   'B.A }}}',
  \   'B.4',
  \   'B }}}',
  \   '2',
  \   'D {{{',
  \   'D.1',
  \   'D }}}',
  \   '3',
  \   'A {{{',
  \   'A.1',
  \   'A.C {{{',
  \   'A.C.1',
  \   'A.C }}}',
  \   'A.2',
  \   'A.B {{{',
  \   'A.B.1',
  \   'A.B }}}',
  \   'A.3',
  \   'A.A {{{',
  \   'A.A.1',
  \   'A.A }}}',
  \   'A.4',
  \   'A }}}',
  \   '4',
  \   'C {{{',
  \   'C.1',
  \   'C }}}',
  \ ]

  call s:do_test('1foldopen | 21foldopen | %FoldSort!', source, expected)
endfunction

function! s:test_sort_in_case_sensitive_order() abort
  let source = [
  \   'A {{{1',
  \   'A.1',
  \   'a {{{1',
  \   'a.1',
  \   'B {{{1',
  \   'B.1',
  \   'b {{{1',
  \   'b.1',
  \ ]
  let expected = [
  \   'A {{{1',
  \   'A.1',
  \   'B {{{1',
  \   'B.1',
  \   'a {{{1',
  \   'a.1',
  \   'b {{{1',
  \   'b.1',
  \ ]

  call s:do_test('%FoldSort', source, expected)
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

function! s:swap(elements, i, j) abort
  let tmp = a:elements[a:i]
  let a:elements[a:i] = a:elements[a:j]
  let a:elements[a:j] = tmp
endfunction

function! s:do_test(command, source, expected) abort
  new
  setlocal foldmethod=marker
  call setline(1, a:source)
  execute a:command
  call assert_equal(a:expected, getline(1, line('$')))
  bdelete!
endfunction
