call plug#begin()

Plug 'preservim/nerdtree'
" theme
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'

" chromium extension
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
" git
Plug 'tpope/vim-fugitive' 
Plug 'rhysd/git-messenger.vim'

" completion
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-endwise'
Plug 'ekalinin/Dockerfile.vim'

" linter
Plug 'dart-lang/dart-vim-plugin'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'dense-analysis/ale'
Plug 'kchmck/vim-coffee-script'
Plug 'fatih/vim-go'

" fzf
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" html jinja
Plug 'lepture/vim-jinja'

" If you have nodejs and yarn
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

call plug#end()

set clipboard=unnamedplus
tmap <Esc> <C-\><C-n>
set splitbelow
set splitright
set mouse=a
set hidden

source ~/.config/nvim/theme.vim
source ~/.config/nvim/fzf.vim
source ~/.config/nvim/linter.vim
source ~/.config/nvim/completion.vim
source ~/.config/nvim/git.vim
source ~/.config/nvim/xml.vim
source ~/.config/nvim/django.vim
source ~/.config/nvim/shortcuts.vim

let g:coc_disable_startup_warning = 1
