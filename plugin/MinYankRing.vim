" Issues:
" 1. Using P to replace the visual selection seems to overwrite the numbered
"    registers in some cases.
"    For an idea to avoid touching the numbered registers, see:
"    http://stackoverflow.com/questions/290465/vim-how-to-paste-over-without-overwriting-register
"
" 2. Using P repeatedly also fills up the undo stack. A paste should still
"    only be one action.
"
" 3. Until now, the script doesn't honor the register passed to the p and P
"    commands, so stuff like "aP doesn't work anymore.

let s:reg_index = 0

function! s:MYR_Replace()
	execute 'normal!`[v`]"' . s:reg_index . 'P'
endfunction

function! MYR_ReplaceNext()
	let s:reg_index = (s:reg_index + 1) % 10
	call s:MYR_Replace()
endfunction

function! MYR_ReplacePrev()
	let s:reg_index = s:reg_index == 0 ? 9 : (s:reg_index - 1)
	call s:MYR_Replace()
endfunction

function! MYR_Paste(pasteFun)
	execute 'normal!' . a:pasteFun
	let s:reg_index = 0
	nnoremap <silent> <buffer> <script> <C-N> :call MYR_ReplaceNext()<CR>
	nnoremap <silent> <buffer> <script> <C-P> :call MYR_ReplacePrev()<CR>
endfunction

nnoremap <silent> <buffer> <script> P :call MYR_Paste('P')<CR>
nnoremap <silent> <buffer> <script> p :call MYR_Paste('p')<CR>

" For debugging purposes
function! MYR_FillReg()
	for i in range(10)
		execute 'let @' . i . '=' . i
	endfor
endfunction
