let s:regIndex = -1
let s:cmdReg   = '"'
let s:pasteFun = "P"
let s:numReg   = {}
let s:ignoreCursorMoved = 0

function! s:MYR_StoreNumberedRegisters()
	" FIXME:
	" Do I need to store the contents of s:cmdReg, too? E.g. what happens
	" if s:cmdReg is one of the numbered registers?
	let s:numReg = {}
	for i in range(10)
		let s:numReg[i] = @i
	endfor
endfunction

function! s:MYR_RestoreNumberedRegisters()
	for i in range(10)
		let @i = s:numReg[i]
	endfor
endfunction

function! s:MYR_Replace()
	let l:reg = -1 == s:regIndex ? s:cmdReg : s:regIndex
	let s:ignoreCursorMoved = 1
	undo
	let s:ignoreCursorMoved = 1
	" FIXME:
	" If the paste went to the very end of the file (i.e. was appended),
	" the [ mark will be invalid.
	execute 'normal!`["' . l:reg . 'P'
endfunction

function! MYR_ReplaceNext()
	let s:regIndex = s:regIndex == 9 ? -1 : (s:regIndex + 1)
	call s:MYR_Replace()
endfunction

function! MYR_ReplacePrev()
	let s:regIndex = s:regIndex == -1 ? 9 : (s:regIndex - 1)
	call s:MYR_Replace()
endfunction

function! s:MYR_Abort()
	if 0 != s:ignoreCursorMoved
		let s:ignoreCursorMoved = 0
		return
	endif
	call s:MYR_RestoreNumberedRegisters()
	nunmap <buffer> <C-N>
	nunmap <buffer> <C-P>
	augroup MYR
		au!
	augroup END
endfunction

function! MYR_Paste(reg, pasteFun)
	call s:MYR_StoreNumberedRegisters()
	let s:regIndex = -1
	let s:cmdReg   = a:reg
	let s:pasteFun = a:pasteFun
	execute 'normal!"' . a:reg . a:pasteFun
	" FIXME:
	" Don't know why, but the paste command above seems to trigger the
	" autocommand defined below.
	let s:ignoreCursorMoved = 1
	nnoremap <silent> <buffer> <script> <C-N> :call MYR_ReplaceNext()<CR>
	nnoremap <silent> <buffer> <script> <C-P> :call MYR_ReplacePrev()<CR>
	augroup MYR
		au!
		au CursorMoved * call s:MYR_Abort()
	augroup END
endfunction

nnoremap <silent> <script> P :call MYR_Paste(v:register, 'P')<CR>
nnoremap <silent> <script> p :call MYR_Paste(v:register, 'p')<CR>
