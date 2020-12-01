" Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-endwise'
" Plug 'ekalinin/Dockerfile.vim'

autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType css,sass,scss setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript,js setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

autocmd FileType python set sw=4
autocmd FileType python set ts=4
autocmd FileType python set sts=4

autocmd BufNewFile,BufRead *.rb set shiftwidth=2|set softtabstop=2|set tabstop=2
autocmd BufNewFile,BufRead *.yml set shiftwidth=2|set softtabstop=2|set tabstop=2
autocmd BufNewFile,BufRead *.haml set shiftwidth=2|set tabstop=2|set softtabstop=2
autocmd BufNewFile,BufRead *.scss set shiftwidth=2|set tabstop=2|set softtabstop=2
autocmd BufNewFile,BufRead *.c set shiftwidth=4|set tabstop=4|set softtabstop=4
autocmd BufNewFile,BufRead *.js set shiftwidth=4|set tabstop=4|set softtabstop=4
autocmd BufNewFile,BufRead Dockerfile* set shiftwidth=4|set tabstop=4|set softtabstop=4
autocmd BufNewFile,BufRead *.html set shiftwidth=2|set tabstop=2|set softtabstop=2
autocmd BufNewFile,BufRead *.php set shiftwidth=2|set tabstop=2|set softtabstop=2

filetype plugin indent on
filetype on
filetype indent on
set autoindent
