function! jgrowl#OpenVimfiler() abort
    "" This doesn't do exactly the behavior I want.
    "" I want to show the current file in vimfiler even if it is a dotfile
    "" For some reason it only shows it when you drill into the folder
    "" It is better than nothing though!

    " let b:vimfiler.is_visible_ignore_files = !b:vimfiler.is_visible_ignore_files
    "
    " if bufnr('vimfiler') == -1
    " vimfiler_toggle_visible_dot_files
    "
    " let b:vimfiler.is_visible_ignore_files = 0
    "
    " vimfiler#toggle_visible_ignore_files()
    silent VimFiler -find
    " if exists(':AirlineRefresh')
    "     AirlineRefresh
    " endif
    " wincmd p
    " if &filetype !=# 'startify'
    "     IndentLinesToggle
    "     IndentLinesToggle
    " endif
    " wincmd p
endfunction
