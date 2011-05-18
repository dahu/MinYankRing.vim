let s:regIndex = -1  " Current register index. -1 for s:cmdReg, 0-9 for the
                     " respective numbered register.
let s:cmdReg   = '"' " Register used with the initial paste.
let s:pasteFun = "P" " Paste command used. Either P or p.
let s:pastePos = []  " Cursor position when paste was issued.
let s:ignoreCursorMoved = 0 " When != 0, the CursorMoved event will not abort
                            " the kill-ring mode.

function! s:MYR_Replace()
	let l:reg = -1 == s:regIndex ? s:cmdReg : s:regIndex
	let s:ignoreCursorMoved = 1
	keepjumps undo
	let s:ignoreCursorMoved = 1
	keepjumps call setpos(".", s:pastePos)
	let s:ignoreCursorMoved = 1
	keepjumps execute 'normal!"' . l:reg . s:pasteFun
endfunction

function! s:MYR_ReplaceNext()
	let s:regIndex = s:regIndex == 9 ? -1 : (s:regIndex + 1)
	call <SID>MYR_Replace()
endfunction

function! s:MYR_ReplacePrev()
	let s:regIndex = s:regIndex == -1 ? 9 : (s:regIndex - 1)
	call <SID>MYR_Replace()
endfunction

function! s:MYR_Abort()
	if 0 != s:ignoreCursorMoved
		let s:ignoreCursorMoved = 0
		return
	endif
	nunmap <buffer> <C-N>
	nunmap <buffer> <C-P>
	augroup MYR
		au!
	augroup END
endfunction

function! s:MYR_Paste(reg, pasteFun)
	let s:regIndex = -1
	let s:cmdReg   = a:reg
	let s:pasteFun = a:pasteFun
	let s:pastePos = getpos(".")
	execute 'normal!"' . a:reg . a:pasteFun
	" FIXME:
	" Don't know why, but the paste command above seems to trigger the
	" autocommand defined below.
	let s:ignoreCursorMoved = 1
	nnoremap <silent> <buffer> <C-N> :call <SID>MYR_ReplaceNext()<CR>
	nnoremap <silent> <buffer> <C-P> :call <SID>MYR_ReplacePrev()<CR>
	augroup MYR
		au!
		au CursorMoved,BufLeave * call <SID>MYR_Abort()
	augroup END
endfunction

nnoremap <silent> P :call <SID>MYR_Paste(v:register, 'P')<CR>
nnoremap <silent> p :call <SID>MYR_Paste(v:register, 'p')<CR>
