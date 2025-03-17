" command_palette.vim - Sublime-style command palette for Vim
" Maintainer: Your Name <your@email.com>

if exists('g:loaded_command_palette') || &cp
  finish
endif
let g:loaded_command_palette = 1

" Configuration
let g:command_palette_commands = get(g:, 'command_palette_commands', [
      \ { 'name': 'New File',          'command': 'enew' },
      \ { 'name': 'Open File...',      'command': 'edit' },
      \ { 'name': 'Save File',         'command': 'w' },
      \ { 'name': 'Save As...',        'command': 'saveas' },
      \ { 'name': 'Toggle Line Numbers', 'command': 'set number!' },
      \ { 'name': 'Toggle Relative Numbers', 'command': 'set relativenumber!' },
      \ { 'name': 'Toggle Paste Mode', 'command': 'set paste!' },
      \ { 'name': 'Command Palette',   'command': 'CommandPalette' },
      \ ])

function! s:FuzzyMatch(items, query) abort
  let l:query = tolower(a:query)
  let l:matches = []

  for item in a:items
    let l:name = tolower(item.name)
    let l:score = 0
    let l:pos = 0
    let l:match = 1

    for c in split(l:query, '\zs')
      let l:idx = stridx(l:name, c, l:pos)
      if l:idx == -1
        let l:match = 0
        break
      endif
      let l:pos = l:idx + 1
    endfor

    if l:match
      call add(l:matches, item)
    endif
  endfor

  return l:matches
endfunction

function! s:FormatCommands(commands) abort
  let l:max_width = 0
  for cmd in a:commands
    let l:max_width = max([l:max_width, len(cmd.name)])
  endfor

  let l:formatted = []
  for cmd in a:commands
    let l:padding = repeat(' ', l:max_width - len(cmd.name) + 2)
    call add(l:formatted, cmd.name . l:padding . cmd.command)
  endfor
  return l:formatted
endfunction

function! commandpalette#Open() abort
  " Get all Vim commands and combine with custom commands
  let l:all_commands = getcompletion('', 'command')
  let l:commands = map(copy(l:all_commands), {_, cmd -> {'name': cmd, 'command': cmd}})
  let l:commands += g:command_palette_commands

  " Get user input
  let l:query = input('> ')
  if empty(l:query)
    return
  endif

  " Fuzzy match commands
  let l:filtered = s:FuzzyMatch(l:commands, l:query)

  if empty(l:filtered)
    echo 'No matches found'
    return
  endif

  " Format and display results
  let l:formatted = s:FormatCommands(l:filtered)
  let l:choice = inputlist(['Select command:'] + l:formatted)

  if l:choice > 0 && l:choice <= len(l:filtered)
    let l:selected = l:filtered[l:choice - 1].command
    execute l:selected
  endif
endfunction

" Key mapping (use <C-S-p> or <D-p> depending on your system)
nnoremap <silent> <C-S-p> :call commandpalette#Open()<CR>
inoremap <silent> <C-S-p> <ESC>:call commandpalette#Open()<CR>