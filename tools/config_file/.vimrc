" vundle settings
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
"Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" Plugin 'file:///home/gmarik/pat:/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
" airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" dash
Plugin 'rizzatti/dash.vim'
Plugin 'rust-lang/rust.vim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help " :PluginList       - lists configured plugins " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate " :PluginSearch foo - searches for foo; append `!` to refresh local cache " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal " " see :h vundle for more details or wiki for FAQ " Put your non-Plugin stuff after this line " line number
set number

" color scheme
syntax enable
"set background=dark
" colorscheme solarized
colorscheme molokai

" real time search
set incsearch
set hlsearch

" high light current line
set cursorline
set cursorcolumn

" ignore upcase and downcase
set ignorecase

" smart fill command
set wildmenu

" tab set
set ts=4
" set softtabstop=4
" set expandtab
" set autoindent

" encoding
set fileencodings=utf-8,gb18030,cp936,big5

" 禁止光标闪烁
set gcr=a:block-blinkon0

" 总是显示状态栏
set laststatus=2

" powerline plugin
let g:Powerline_clolorsymbol = 'solarized256'

" 类型检查
filetype on
filetype plugin on
filetype indent on

" indent显示插件
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=1

" 代码折叠 
set foldmethod=indent
set nofoldenable

" autocmd VimEnter * NERDTree
let g:airline_theme="luna" 

" nerdtree
let g:nerdtree_tabs_open_on_console_startup=1
" autocmd vimenter * NERDTree " 自动打开nerdtree
command NN NERDTree
map <F3> <Esc>:NERDTree<CR>
let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }

autocmd BufWritePost $MYVIMRC source $MYVIMRC
    

