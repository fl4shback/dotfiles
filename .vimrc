" Search and Navigation
set ignorecase          " Case-insensitive search
set smartcase           " But case-sensitive if you use capitals
set incsearch           " Show matches as you type
set hlsearch            " Highlight search results
set shortmess-=S        " Show number of search matches 
set number              " Show line numbers
set relativenumber      " Relative line numbers (great for motions)

" Indentation and Formatting
set expandtab           " Use spaces instead of tabs
set tabstop=4           " Tab width
set shiftwidth=4        " Indentation width
set autoindent          " Copy indent from current line
set smartindent         " Smart autoindenting

" Usability
set mouse=a             " Enable mouse support
set ttymouse=xterm2
set clipboard=unnamed   " Use system clipboard (macOS)
set wildmenu            " Better command-line completion
set wildmode=longest:full,full
set backspace=indent,eol,start  " Sane backspace behavior
set showcmd             " Show partial commands
set showmatch           " Highlight matching brackets
set scrolloff=5         " Keep 5 lines visible above/below cursor

" Visual feedback
set cursorline          " Highlight current line
set ruler               " Show cursor position
set laststatus=2        " Always show status line
syntax on               " Syntax highlighting
colorscheme desert

" Clear search highlighting with Ctrl+L
nnoremap <C-L> :nohlsearch<CR><C-L>
