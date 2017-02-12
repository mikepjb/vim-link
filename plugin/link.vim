let s:python_dir = fnamemodify(expand("<sfile>"), ':p:h:h') . '/python'

function! s:shellesc(arg) abort
  if a:arg =~ '^[A-Za-z0-9_/.-]\+$'
    return a:arg
  elseif &shell =~# 'cmd'
    throw 'Python interface not working. See :help python-dynamic'
  else
    let escaped = shellescape(a:arg)
    if &shell =~# 'sh' && &shell !~# 'csh'
      return substitute(escaped, '\\\n', '\n', 'g')
    else
      return escaped
    endif
  endif
endfunction

function! s:dict(string_dict) abort
  execute("let dictout = " . a:string_dict)
  return dictout
endfunction

function! s:get_visual_selection()
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

function! link#background_command_close(channel)
  let output = readfile(g:background_command_output)
  let g:previous_command_output = g:background_command_output
  for line in output
    let dline = s:dict(line)
    if has_key(dline, 'value')
      echo dline['value']
    endif
    if has_key(dline, 'out')
      let g:link#output = dline['out']
      echom dline['out']
    endif
  endfor
  unlet g:background_command_output
endfunction

" XXX rename to send_to_nrepl or similar
" XXX also should have an options var that can choose what op to use
" e.g load-file vs eval
function! link#run_background_command(code)
  if v:version < 800
    echoerr 'run_background_command requires VIM version 8 or higher'
    return
  endif

  echom 'Evaluating...'
  let g:background_command_output = tempname()
  let command = 'python'
        \ . ' ' . s:shellesc(s:python_dir.'/nrepl_client.py')
        \ . ' ' . s:shellesc(a:code)
  call job_start(command,
        \ {'close_cb': 'link#background_command_close',
        \ 'out_io': 'file',
        \ 'out_name': g:background_command_output})
endfunction

" command! -nargs=1 Eval :call link#run_background_command(<q-args>)
" XXX include -complete function
" XXX investigate the -bang flag, what does this mean?
command! -buffer -range=0 -nargs=? Eval :call ui#eval_input_handler(<line1>, <line2>, <count>, <q-args>)
command! Log :execute(":belowright 10split" .  g:previous_command_output)
vmap <CR> :Eval<CR>
" command! -range Eval :call link#run_background_command(<count>)
" vmap <CR>
" nnoremap <silent> <Plug>Eval :exe <SID>print_last()<CR>
" nnoremap <silent> <Plug>Eval :call link#run_background_command(<q-args>)
" nnoremap <silent> <Plug>FireplacePrintLast :exe <SID>print_last()<CR>
