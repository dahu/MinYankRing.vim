" Issues:
" 1. Using P to replace the visual selection seems to overwrite the numbered
"    registers in some cases.
"    For an idea to avoid touching the numbered registers, see:
"    http://stackoverflow.com/questions/290465/vim-how-to-paste-over-without-overwriting-register
"
" 2. Using P repeatedly also fills up the undo stack. A paste should still
"    only be one action.

let s:reg_index = -1
let s:cmd_reg   = '"'

function! s:MYR_Replace()
	let l:reg = -1 == s:reg_index ? s:cmd_reg : s:reg_index
	execute 'normal!`[v`]"' . l:reg . 'P'
endfunction

function! MYR_ReplaceNext()
	let s:reg_index = s:reg_index == 9 ? -1 : (s:reg_index + 1)
	call s:MYR_Replace()
endfunction

function! MYR_ReplacePrev()
	let s:reg_index = s:reg_index == -1 ? 9 : (s:reg_index - 1)
	call s:MYR_Replace()
endfunction

function! MYR_Paste(reg, pasteFun)
	execute 'normal!"' . a:reg . a:pasteFun
	let s:reg_index = -1
	let s:cmd_reg   = a:reg
	echo "cmd_reg = " s:cmd_reg
	nnoremap <silent> <buffer> <script> <C-N> :call MYR_ReplaceNext()<CR>
	nnoremap <silent> <buffer> <script> <C-P> :call MYR_ReplacePrev()<CR>
endfunction

nnoremap <silent> <buffer> <script> P :call MYR_Paste(v:register, 'P')<CR>
nnoremap <silent> <buffer> <script> p :call MYR_Paste(v:register, 'p')<CR>

" For debugging purposes
function! MYR_FillReg()
	for i in range(10)
		execute 'let @' . i . '=' . i
	endfor
endfunction
