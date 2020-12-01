nnoremap <C-w>f :tabe %<CR>

tmap <C-w>j <ESC><C-w>j
tmap <C-w>k <ESC><C-w>k
tmap <C-w>h <ESC><C-w>h
tmap <C-w>l <ESC><C-w>l

tmap <C-w><C-j> <ESC><C-w>j
tmap <C-w><C-k> <ESC><C-w>k
tmap <C-w><C-h> <ESC><C-w>h
tmap <C-w><C-l> <ESC><C-w>l

tmap <C-l>         <ESC><C-l>i
tmap <C-h>         <ESC><C-h>i
tmap <C-j>         <ESC><C-j>i
tmap <C-k>         <ESC><C-k>i
tmap <C-o>	<ESC><C-o>

" autocmd BufLeave term://* stopinsert
autocmd BufWinEnter,WinEnter term://* startinsert
noremap <C-l>         :vertical resize +3<CR>
noremap <C-h>         :vertical resize -3<CR>
noremap <C-j>         <C-w>-
noremap <C-k>         <C-w>+

