" POC that provides asynchronous cpp functionality from vim-fireplace
" XXX check for python 2 on command line!!!

" XXX this requires one less :h than vim-fireplace, why?
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

function! s:escape_quotes(arg) abort
  " XXX check if quotes are in the string before substituting
  return substitute(a:arg, '\"', '\\\"', 'g')
endfunction

" This callback will be executed when the entire command is completed
function! link#background_command_close(channel)
  " Read the output from the command into the quickfix window
  execute "cfile! " . g:background_command_output
  " Open the quickfix window
  copen
  unlet g:background_command_output
endfunction

function! link#testargs(code)
  echo s:shellesc('"' . a:code . '"')
endfunction

function! link#run_background_command(code)
  " Make sure we're running VIM version 8 or higher.
  if v:version < 800
    echoerr 'run_background_command requires VIM version 8 or higher'
    return
  endif

  if exists('g:background_command_output')
    echo 'Already running task in background'
  else
    echo 'Running task in background'
    " Launch the job.
    " Notice that we're only capturing out, and not err here. This is because, for some reason, the callback
    " will not actually get hit if we write err out to the same file. Not sure if I'm doing this wrong or?
    let g:background_command_output = tempname()
    let command = 'python'
          \ . ' ' . s:shellesc(s:python_dir.'/nrepl_client.py')
          \ . ' ' . s:shellesc(a:code)
    " XXX debug
          " \ . ' ' . s:shellesc(a:code)
    echo command
    call job_start(command, {'close_cb': 'link#background_command_close', 'out_io': 'file', 'out_name': g:background_command_output})
  endif
endfunction
