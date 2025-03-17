" command_palette.vim

if exists('g:loaded_command_palette')
    finish
endif
let g:loaded_command_palette = 1

function! s:FuzzyMatch(str, pattern)
    let l:pattern = substitute(a:pattern, '.', '\\&\\.\\*', 'g')
    return a:str =~? l:pattern
endfunction

function! s:UpdateMatches()
    let s:matches = filter(copy(s:command_list), 's:FuzzyMatch(v:val, s:filter)')
    %delete _
    call setline(1, s:matches)
    redraw
    echo 'Filter: ' . s:filter
endfunction

function! s:FilterAdd(char)
    let s:filter .= a:char
    call s:UpdateMatches()
endfunction

function! s:FilterBackspace()
    if len(s:filter) > 0
        let s:filter = s:filter[:-2]
        call s:UpdateMatches()
    endif