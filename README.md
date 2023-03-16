# foldsort

**foldsort** is a plugin to provide a command to sort fold regions in the range.

## Requirements

- Vim 8.0 or later

## Usage

Suppose there is the following content that contain some folds in the buffer:

```
+--  2 lines: function! B()  -----------------------------------------

+--  2 lines: function! C()  -----------------------------------------

+--  2 lines: function! A()  -----------------------------------------
```

You can execute `:FoldSort` command to sort fold regions that are closed:

```
+--  2 lines: function! A()  -----------------------------------------

+--  2 lines: function! B()  -----------------------------------------

+--  2 lines: function! C()  -----------------------------------------
```

## Documentation

You can access the [documentation](https://github.com/emonkak/foldsort/blob/master/doc/foldsort.txt) from within Vim using `:help foldsort`.
