" POC that provides asynchronous cpp functionality from vim-fireplace

function! fireplace#session_eval(expr, ...) abort
  let response = s:eval(a:expr, a:0 ? a:1 : {})

  if !empty(get(response, 'value', '')) || !empty(get(response, 'err', ''))
    call insert(s:history, {'buffer': bufnr(''), 'code': a:expr, 'ns': fireplace#ns(), 'response': response})
  endif
  if len(s:history) > &history
    call remove(s:history, &history, -1)
  endif

  if !empty(get(response, 'stacktrace', []))
    let nr = 0
    if has_key(s:qffiles, expand('%:p'))
      let nr = winbufnr(s:qffiles[expand('%:p')].buffer)
    endif
    if nr != -1
      call setloclist(nr, fireplace#quickfix_for(response.stacktrace))
    endif
  endif

  try
    silent doautocmd User FireplaceEvalPost
  catch
    echohl ErrorMSG
    echomsg v:exception
    echohl NONE
  endtry

  call s:output_response(response)

  if get(response, 'ex', '') !=# ''
    let err = 'Clojure: '.response.ex
  elseif has_key(response, 'value')
    return response.value
  else
    let err = 'fireplace.vim: Something went wrong: '.string(response)
  endif
  throw err
endfunction

function! fireplace#echo_session_eval(expr, ...) abort
  try
    echo fireplace#session_eval(a:expr, a:0 ? a:1 : {})
  catch /^Clojure:/
  catch
    echohl ErrorMSG
    echomsg v:exception
    echohl NONE
  endtry
  return ''
endfunction

function! s:print_last() abort
  call fireplace#echo_session_eval(s:todo, {'file_path': s:buffer_path()})
  return ''
endfunction


