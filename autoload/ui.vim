" XXX wtf does bang mean in this context?

" XXX I don't understand the rele:w

let ui#skip = 'synIDattr(synID(line("."),col("."),1),"name") =~? "comment\\|string\\|char\\|regexp"'
let ui#open = '[[{(]'
let ui#close = '[]})]'

function! ui#eval_input_handler(line1, line2, count, args) abort
  let options = {}
  if a:args !=# '' " if :Eval <statement>
    let expr = a:args
  else
    if a:count ==# 0 " what?!? maybe press 3:Eval?
      let [start_line, start_col] = ui#current_sexp_position('bcrn')
      let [end_line, end_col] = ui#current_sexp_position('rn')
      if !start_line && !end_start
        let [start_line, start_col] = ui#current_sexp_position('brn')
        let [end_line, end_col] = ui#current_sexp_position('crn')
      endif
      while col1 > 1 && getline(line1)[col1-2] =~# '[#''`~@]'
        let col1 -= 1
      endwhile
    else
      let start_line = a:line1
      let end_line = a:line2
      let start_col = 1
      let end_col = strlen(getline(end_line))
    endif
    if !start_line || !end_line
      return ''
    endif
    let options.file_path = s:buffer_path()
    if expand('%:e') ==# 'cljs'
      "leading line feed don't work on cljs repl
      let expr = ''
    else
      let expr = repeat("\n", start_line-1).repeat(" ", start_col-1)
    endif
    if start_line == end_line
      let expr .= getline(start_line)[start_col-1 : end_col-1]
    else
      let expr .= getline(start_line)[start_col-1 : -1] . "\n"
            \ . join(map(getline(start_line+1, end_line-1), 'v:val . "\n"'))
            \ . getline(end_line)[0 : end_col-1]
    endif
  endif
  call link#run_background_command(expr)
endfunction
