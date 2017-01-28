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

function! link#background_command_close(channel)
  let output = readfile(g:background_command_output)
  for line in output
    let dline = s:dict(line)
    if has_key(dline, 'value')
      echo dline['value']
    endif
    if has_key(dline, 'out')
      echo dline['out']
    endif
  endfor
  unlet g:background_command_output
endfunction

function! link#run_background_command(code)
  if v:version < 800
    echoerr 'run_background_command requires VIM version 8 or higher'
    return
  endif

  if exists('g:background_command_output')
    echo 'Already running task in background'
  else
    echom 'Running task in background'
    let g:background_command_output = tempname()
    let command = 'python'
          \ . ' ' . s:shellesc(s:python_dir.'/nrepl_client.py')
          \ . ' ' . s:shellesc(a:code)
    call job_start(command,
          \ {'close_cb': 'link#background_command_close',
          \ 'out_io': 'file',
          \ 'out_name': g:background_command_output})
  endif
endfunction

command! -nargs=1 Eval :call link#run_background_command(<q-args>)
" nnoremap <silent> <Plug>Eval :exe <SID>print_last()<CR>
" nnoremap <silent> <Plug>Eval :call link#run_background_command(<q-args>)
" nnoremap <silent> <Plug>FireplacePrintLast :exe <SID>print_last()<CR>
