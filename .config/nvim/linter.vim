" Plug 'dart-lang/dart-vim-plugin'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}

" fold settings
set foldmethod=syntax
set nofoldenable

" ale settings
" Set specific linters
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'ruby': ['rubocop'],
\}
" Only run linters named in ale_linters settings.
let g:ale_linters_explicit = 1 
let g:airline#extensions#ale#enabled = 1 
let g:ale_sign_column_always = 1
