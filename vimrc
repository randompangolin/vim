" pangolin's vimrc

" basic
set nocompatible
" colorscheme solarized
" optimal = less than or equal to 19 lines
" 65 x 18
set number relativenumber
syntax on
" smartindent is not good
set autoindent
filetype indent on
set tabstop=4
set softtabstop=4
set shiftwidth=4

" misc
inoremap jj <Esc>
nnoremap ^ 0
nnoremap 0 ^
autocmd CursorMoved * normal zz
autocmd CursorMovedI * call InsertCenterCursor()
function InsertCenterCursor()
	let l = line(".")
	let c = col(".")
	normal zz
	if c == col("$")
		call cursor(l, col("$"))
	endif
endfunction
set autochdir
autocmd BufWritePre * :%s/\s\+$//e
autocmd BufEnter * setlocal formatoptions-=ro

" search
set hlsearch
set incsearch
set ignorecase
set smartcase
" nnoremap <silent> <CR> :nohlsearch<CR>
augroup AutoHighlighting
    autocmd!
    autocmd CmdlineEnter /,\? set hlsearch
    autocmd CmdlineLeave /,\? set nohlsearch
augroup END

" ui
set ruler
set showcmd

function Run()
	write
	if &filetype == "c"
		!gcc -Wall % -o %< && ./%<
	elseif &filetype == "cpp"
		!g++ -Wall -std=c++11 % -o %< && ./%<
	elseif &filetype == "python"
		!python3 %
	endif
	" display .out file if there is one
	if filereadable(expand("%<") .. ".out")
		!cat %<.out
	endif
endfunction

function Comment(m) " 0 = normal, 1 = visual
	let c = get({"c" : "//", "cpp" : "//", "python" : "#", "vim" : "\""}, &filetype)
	if a:m == 0
		let l = line(".")
		let r = line(".")
	else
		let l = line("'<")
		let r = line("'>")
	endif
	" check if lines are commented already
	let f = 1
	for i in range(l, r)
		if matchstr(getline(i), "^\s*" .. c) == ""
			let f = 0
			break
		endif
	endfor
	" take appropriate measures
	for i in range(l, r)
		let s = getline(i)
		if f == 0
			if matchstr(s, "^\s*" .. c) == ""
				let s = c .. " " .. s
			endif
		else
			let s = substitute(s, "^\s*" .. c .. " ", "", "")
		endif
		call setline(i, s)
	endfor
endfunction

" function LoadTemplate()
" 	call deletebufline("", 1, line("$"))
" 	execute "read ~/.vim/templates/template." .. &filetype
" 	call deletebufline("", 1)
" 	if &filetype == "c" || &filetype == "cpp"
" 		call append(3, "\t")
" 		startinsert
" 		call cursor(4, 2)
" 	endif
" endfunction

function LoadTemplate(...)
	if a:0 == "" " auto file type template
		call deletebufline("", 1, line("$"))
		execute "read ~/.vim/templates/template." .. &filetype
		call deletebufline("", 1)
		if &filetype == "c" || &filetype == "cpp"
			call append(3, "\t")
			startinsert
			call cursor(4, 2)
		endif
	elseif a:1 == "usaco"
		call deletebufline("", 1, line("$"))
		execute "read ~/.vim/templates/usaco.c"
		call deletebufline("", 1)
		call setline(4, substitute(getline(4), "fin", expand("%<"), ""))
		call setline(5, substitute(getline(5), "fout", expand("%<"), ""))
		call append(5, expand("\t"))
		startinsert
		call cursor(6, 2)
	else " misc tools
		" save cursor position
		let l = line(".")
		let c = col(".")
		" place code after library or define
		for i in range(1, line("$"))
			if getline(i)[0] != "#"
				break
			endif
		endfor
		" load
		let f = readfile(expand("~/.vim/templates/" .. a:1))
		call append(i - 1, f)
		" load saved cursor position
		call cursor(l + len(f), c)
	endif
endfunction

function InsertForLoop(s)
	let i = matchstr(getline("."), "^\s*")
	let l = "for (int _ = " .. a:s .. "; _ <= _; ++_)"
	stopinsert
	call setline(line("."), i .. l)
	call cursor(line("."), len(i) + 10)
endfunction

function ExpandSnippet(trigger)
	let content = g:snippet_dict[trigger]
	let indent = matchstr(line, "^\s*")
	let lines = split(content, "\n")
	let firstline = indent . substitute(lines[0], '^snippet\s\+\zs\S\+\ze\s\+".\+"', '', '')
	let lastline = indent . substitute(lines[-1], '^endsnippet', '', '')
	let body = map(lines[1 : -2], "indent .. v:val")
	call append(line("."), firstline)
	call append(line("$"), body)
	call append(line("$"), firstline)
	return ""
endfunction

function Tab()
	" snippet
	let l = getline(".")
	let	start_col = col(".") - 1
	let end_col = search('\<bar>\|\<cr>\|\<tab>\|\<bs>\|\<del>\|\<esc>\|\<space>', 'bcnW') - 1
	let trigger = strpart(l, start_col, start_col - end_col)
	if snippeting == 1
		:
	if has_key(g:snippet_dict, trigger)
		call ExpandSnippet(trigger)
	elseif l[col(".") - 2] !~ "^\s?$" || pumvisible()
		return "<C-n>"
	else
		return "<Tab>"
endfunction

" function IntToUnsignedLongLong()
" 	let s = getcurpos()
" 	call cursor(1, 0)
" 	while search("int") != 0
" 		a
" 	call setpos(".", s)
" endfunction

function Test()
	echo "Test() was run"
	" Preserve `int main()`
    %s/\c\<int\>\(\s\+main\s*(\)/~SPECIAL_INT_MAIN~/g

    " Replace `int` with `unsigned long long`
    %s/\c\<int\>/unsigned long long/g

    " Restore `int main()`
    %s/\c~SPECIAL_INT_MAIN~/int main (/g

    " Replace all `%d` with `%llu`
    %s/%d/%llu/g

    " Restore `int` in `for` loop counters
    %s/\cfor\s*(\s*unsigned long long\s\+\(\k\+\)\s*\(.*\)\s*\(\k\+\)\s*<\s*\(\k\+\)\s*;\s*\3\+\+\s*)/for (int \1 \2 \3 < \4; \3++)/g
endfunction

" key binds
let mapleader = " "
nnoremap <leader>d :%d<CR>i
nnoremap <leader>y :w<CR>:%y*<CR>
nnoremap <leader>Y :y*<CR>
vnoremap <leader>y "*y
vnoremap <leader>Y "*Y
nnoremap <leader>r :call Run()<CR>
nnoremap <leader>t :call LoadTemplate()<CR>
nnoremap <leader>/ :call Comment(0)<CR>
vnoremap <leader>/ :<C-u>call Comment(1)<CR>
nnoremap <leader>T :call Test()<CR>
nnoremap <leader>g 2g;
nnoremap <leader>l :call IntToUnsignedLongLong()<CR>

" nnoremap <leader>m :call LoadTemplate("min_max.c")<CR>
" nnoremap <leader>s :call LoadTemplate("sort.c")<CR>
nnoremap <leader>u :call LoadTemplate("usaco")<CR>
" windows
nnoremap <leader>s <C-w>s
nnoremap <leader>v <C-w>v

nnoremap <leader>w <C-w>w
nnoremap <leader>p <C-w>p

nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

nnoremap <leader>c <C-w>c
nnoremap <leader>o <C-w>o
nnoremap <leader>x <C-w>x

" testing
" autocmd FileType c,cpp inoremap <expr> <leader>f InsertForLoop(0)
" autocmd FileType c,cpp inoremap <leader>f <Esc>:call InsertForLoop(0)<CR>
" autocmd FileType c,cpp inoremap <leader>F <Esc>:call InsertForLoop(1)<CR>
" autocmd FileType c,cpp inoremap <expr> <leader>t Test()

" Tab
" inoremap <expr> <Tab> Tab()
inoremap <expr> <Tab> getline('.')[col('.')-2] !~ '^\s\?$' \|\| pumvisible() ? '<C-n>' : '<Tab>'
