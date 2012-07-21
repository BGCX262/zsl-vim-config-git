set nocompatible

let g:isWin=(has("win32") || has("win64") || has("win32unix"))

let g:isGUI=has("gui_running")

if g:isWin
    let $vimrc = $VIM . "/_vimrc"
    let $vimfiles = $VIM . "/vimfiles"
else
    let $vimrc = "~/.vimrc"
    let $vimfiles = "~/.vim"
endif


source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

"source $VIMRUNTIME/autotag.vim

" ������ʱ����ʾ�Ǹ�Ԯ���������ͯ����ʾ
set shortmess=atI

if has("gui_running")
    if has("gui_win32")
        :set guifont=Consolas:h11
    endif
endif

" ���ô��ڴ�С
if !exists("s:has_inited")
    let s:has_inited = 1
    set lines=42 columns=160
endif

" ������buffer���κεط�ʹ����꣨����office���ڹ�����˫����궨λ��
if has('mouse')
    set mouse=a
endif

set guioptions-=T  "To  Remove toolbar   ����ʾ������
set guioptions+=c
set guioptions+=b

"�Ҽ������˵�
set mousemodel=popup

" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" �ڱ��ָ�Ĵ��ڼ���ʾ�հף������Ķ�
set fillchars=vert:\ ,stl:\ ,stlnc:\

set sidescroll=20

set nobackup

set history =1000
" ��ǿģʽ�е��������Զ���ɲ���
set wildmenu
" ����backspace�͹�����Խ�б߽�
set whichwrap+=<,>,h,l

set statusline=%{expand('%:p:h')}%{g:isWin?'\\':'/'}%2*%t%1*%m%r%h%w%0*%=\ [%1*%{&ff=='unix'?'\\n':(&ff=='dos'?'\\r\\n':'\\r')},%{&fenc},%{&ft}%0*][%2*%02l,%02v,%04o,0x%04B%0*][%1*%{expand('%')!=''?strftime('%Y-%m-%d\ %H:%M:%S',getftime(expand('%:p'))):'-'}%0*][%2*%P%0*]
" ������ʾ״̬��
set laststatus=2
" �ڱ༭�����У������½���ʾ���λ�õ�״̬��
set ruler

" ͨ��ʹ��: commands������������ļ�����һ�б��ı��
set report=0

set incsearch
set hlsearch

set nu
set nuw=4

set tabstop     =4  " ts, number of spaces a tab in the file counts for
set softtabstop =4  " sts, 
set shiftwidth  =4
set smarttab
set et  " ���������Ҫ�ر�, makefile
autocmd FileType make,tags set noexpandtab

set autoindent
set smartindent
set cindent

set ignorecase smartcase

set colorcolumn=121

set matchpairs =(:),[:],{:},<:>

set foldmethod=indent
" set foldmethod=syntax
set foldlevel=100
set foldopen-=search
set foldopen-=undo
set foldcolumn=4

syntax enable
syntax on
filetype plugin indent on

colorscheme desert

" Tag List
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

" Tag Bar
nmap tb :TagbarToggle<cr>
let g:tagbar_ctags_bin = 'ctags'
let g:tagbar_left = 1
let g:tagbar_width = 45
let g:tagbar_expand = 0

" buf explorer
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 30  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
autocmd BufWinEnter \[Buf\ List\] setl nonumber 

" doxygen
" let g:DoxygenToolkit_commentType = "C++"
let g:DoxygenToolkit_versionString = "1.0"
let g:DoxygenToolkit_authorName = "zsl"
let g:DoxygenToolkit_licenseTag = "Copyright (C) " . strftime("%Y") . " Feitian Technologies Co., Ltd. All rights reserved."

" winmanager
let g:winManagerWindowLayout='FileExplorer|TagList'
nmap wm :WMToggle<cr>

set cscopequickfix=" s-,c-,d-,i-,t-,e-
set cst
set csto=0
set csverb
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :cs find t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-\>d :cs find d <C-R>=expand("<cword>")<CR><CR>

nmap <F6> :cn<cr>
nmap <F7> :cp<cr>

set completeopt=longest,menu,menuone 
"�Զ���ʾ
let g:acp_enableAtStartup = 0
let g:acp_mappingDriven = 1
" OmniCppComplete
let g:OmniCpp_NamespaceSearch = 1
let g:OmniCpp_GlobalScopeSearch = 1
let g:OmniCpp_ShowAccess = 1
let g:OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let g:OmniCpp_MayCompleteDot = 1 " autocomplete after .
let g:OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let g:OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let g:OmniCpp_SelectFirstItem = 0
let g:OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD", "boost"]

"-------------------neocomplcache setting -----------------
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
let g:acp_behaviorSnipmateLength = 1
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Use camel case completion.
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
let g:neocomplcache_disable_auto_complete = 0
let g:neocomplcache_enable_auto_select = 0
let g:neocomplcache_force_overwrite_completefunc = 1
" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }
" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
" Plugin key-mappings.
imap <C-k>     <Plug>(neocomplcache_snippets_expand)
smap <C-k>     <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g>     neocomplcache#undo_completion()
inoremap <expr><C-l>     neocomplcache#complete_common_string()

autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
"autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '\%(\.\|->\)\h\w*'
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'

" For snippet_complete marker.
if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" super tab
let g:SuperTabRetainCompletionType=2
let g:SuperTabDefaultCompletionType="<C-X><C-O>"
let g:SuperTabMappingForward = '<c-tab>'
let g:SuperTabMappingTabLiteral = '<tab>'

let g:miniBufExplMapCTabSwitchBufs = 1

" Clang
" let g:clang_use_library = 1
" let g:clang_library_path = "D:/software/devtools/clang/lib"
" let g:clang_auto_select = 1
" let g:clang_complete_macros = 1 
" let g:clang_complete_patterns = 1
" let g:clang_snippets = 1
" let g:clang_snippets_engine = 'clang_complete'

"python�ӿ�

python << EOF_PYTHON

import vim
import sys
import os

#��ʽ�������ļ�
def FormatCode(tp):
    ft = vim.eval('&filetype')
    if ft in ('c', 'cpp', 'java', 'cs'):
        vim.command('normal mx')
        ff = vim.eval('&ff')
        vim.command('set ff=dos') #��unix��β�»���BUG���ĳ�DOS��β
        if tp == 0: #format all code
            vim.command('%!astyle -A1pHcjUnwK -z2 -k1')
        else:
            vim.command("'<,'>!astyle -A1pHcjUnwK -z2 -k1")
        vim.command('set ff=%s' % ff) #�ָ�ԭ������β
        vim.command('normal `x')
    elif ft in ('xml',):
        vim.command('normal mx')
        vim.command(r'''silent! %s/>\(\s*$\)\@!/>\r/g''')
        vim.command(r'''silent! %s/\(^\s*\)\@<!</\r</g''')
        vim.command(r'''normal gg=G''')
        vim.command(r'''silent! %s/\s*$//g''') #ɾ����β�Ŀո�
        vim.command(r'''silent! %m/asd^$(())fajl;''')
        vim.command('normal `x')
    else:
        print >> sys.stderr, "Format code: file type not supported!"

EOF_PYTHON


"vimѡ���ı��������ż��Զ������Ű�Χ
python << PYTHON_EOF
import vim
def AddBracket(bl, br):
    vim.command('''execute "normal gv"''')
    md = vim.eval("mode()")
    if md in ("v", "s"):
        #��֧�ֿ���
        vim.command('''execute "normal s%s\\<LEFT>\\<C-O>p%s\\<ESC>gvlolo\\<ESC>"''' % (bl, br))
    elif md in ("V", "S"):
        start = int(vim.eval('''line("'<")'''))
        end = int(vim.eval('''line("'>")'''))
        vim.current.buffer.append(br, end)
        vim.current.buffer.append(bl, start - 1)
        vim.command('''execute "normal jojo\\<ESC>"''')
    else:
        #must be CTRL-V mode
        vim.command('''execute "normal I%s\\<ESC>gvlA%s\\<ESC>"''' % (bl, br))

PYTHON_EOF

set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

