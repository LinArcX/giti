"-------------- Key-mapping(F2-F11 are free) ------------""
"Switch between .cpp/.hpp files
nnoremap <F2> :FSHere<CR>

call coc#config('languageserver', {
            \ 'vala': {
            \   "command": "vala-language-server",
            \   "filetypes": ["vala"]
            \ }
            \})

"---------- clang-format settings --------""
function! FormatCurrentFile()
    "execute "normal! gg=G"
    "silent execute "!clang-format -style=WebKit -i" . " " . expand('%:p')
    silent execute "!uncrustify -c ./uncrustify.cfg" . " " . expand('%:p') . " " . "--replace --no-backup"
    :e
endfunction
au BufEnter,BufWrite *.vala call FormatCurrentFile()

"------------- vim-quickui settings  ------------------"
let s:update = "update | w |"
let s:meson_build = 'nix-shell --command \"meson build --prefix=/usr; ln -s build/compile_commands.json .; cd build; ninja; \"' . '\n'
let s:project_clear = "clear; rm compile_commands.json; rm -rfv build/**; rm -rfv debug/**; rm -rfv release/**; \n"
let s:ninja_isntall = "cd build; sudo ninja install \n"
let s:ninja_unisntall = "cd build; sudo ninja uninstall \n"

call quickui#menu#clear('P&roject')
" biurc--dwayest
call quickui#menu#install('P&roject', [
            \ [ 'meson(&build)', s:update.'call HTerminal(0.4, 300.0, "'. s:meson_build .'")' ],
            \ [ 'ninja(&install)', s:update.'call HTerminal(0.4, 300.0, "'. s:ninja_isntall .'")' ],
            \ [ 'ninja(&uninstall)', s:update.'call HTerminal(0.4, 300.0, "'. s:ninja_unisntall .'")' ],
            \ [ '&run()', s:update.'call HTerminal(0.4, 300.0, "clear; /usr/bin/'. $FULL_NAME .' \n")' ],
            \ [ '&clean-project', s:update.'call HTerminal(0.4, 300.0, "'. s:project_clear .'")' ],
            \ [ "--", '' ],
            \ [ 'gtk3-&demo', 'call jobstart("gtk3-demo")' ],
            \ [ 'gtk3-&widget-factory', 'call jobstart("gtk3-widget-factory")' ],
            \ [ 'gtk3-demo-&application', 'call jobstart("gtk3-demo-application")' ],
            \ [ 'ke&ys', 'call ExecCommands("Gsettings keys", "!gsettings list-recursively '. $FULL_NAME .'")' ],
            \ [ '&enbale-gtk-inspector', 'call ExecCommands("Gsettings keys", "!gsettings set org.gtk.Settings.Debug enable-inspector-keybinding true")' ],
            \ [ 'di&sable-gtk-inspector', 'call ExecCommands("Gsettings keys", "!gsettings set org.gtk.Settings.Debug enable-inspector-keybinding false")' ],
            \ [ 'rese&t-gsettings', 'call ExecCommands("Reset Gsettings", "!gsettings reset com.github.linarcx.giti directories")' ],
            \ [ "--", '' ],
            \ [ "nix-collect-garbage", 'call HTerminal(0.4, 300.0, "clear; nix-store --gc \n")' ],
            \ ], 5000)

"coiustrpfs
call quickui#menu#install('&Debugging', [
            \ [ "&continue\tF(5)", 'call feedkeys("\<Plug>VimspectorContinue")' ],
            \ [ "step-&over\tF(6)", 'call feedkeys("\<Plug>VimspectorStepOver")' ],
            \ [ "step-&into\tF(7)", 'call feedkeys("\<Plug>VimspectorStepInto")' ],
            \ [ "step-o&ut\tF(8)", 'call feedkeys("\<Plug>VimspectorStepOut")' ],
            \ [ "&stop\tF(9)", 'call feedkeys("\<Plug>VimspectorStop")' ],
            \ [ "&toggle-breakpoint\tF(10)", 'call feedkeys("\<Plug>VimspectorToggleBreakpoint")' ],
            \ [ "&pause\tShift-p", 'call feedkeys("\<Plug>VimspectorPause")' ],
            \ [ "&restart\tShift-r", 'call feedkeys("\<Plug>VimspectorRestart")' ],
            \ [ "clo&se-debugger\tShift-s", ':call vimspector#Reset()' ],
            \ ], 5001)

"rutnpm
call quickui#menu#install('&Test', [
            \ [ "&run", 'GTestRun' ],
            \ [ "run-&under-cursor", 'GTestRunUnderCursor' ],
            \ [ "&toggle-enable", 'GTestToggleEnabled' ],
            \ [ "&next", 'GTestNext' ],
            \ [ "&previous", 'GTestPrev' ],
            \ [ "ju&mp-to-test", 'GTestJump' ],
            \ ], 5002)

"casmgn--pd--eb--xfoiat
call quickui#menu#install('C&oc', [
            \ [ "&config", 'CocConfig' ],
            \ [ "code-&action", 'exec "normal \<Plug>(coc-codeaction)"' ],
            \ [ "codeaction-&selected", 'exec "normal \<Plug>(coc-codeaction-selected)"' ],
            \ [ "co&mmand", 'call feedkeys("\<Plug>(coc-command)")' ],
            \ [ "dia&gnostics", 'exec "normal \<Plug>(coc-diagnostics)"' ],
            \ [ "cha&nnel-output", 'CocCommand workspace.showOutput' ],
            \ [ "--", '' ],
            \ [ "im&plementation", 'call feedkeys("\<Plug>(coc-implementation)")' ],
            \ [ "&definition", 'call feedkeys("\<Plug>(coc-definition)")' ],
            \ [ "--", '' ],
            \ [ "&enable", 'CocEnable' ],
            \ [ "disa&ble", 'CocDisable' ],
            \ [ "--", '' ],
            \ [ "e&xtensions", ':CocList extensions' ],
            \ [ "&fix-current", 'exec "normal \<Plug>(coc-fix-current)"' ],
            \ [ "f&ormat-selected", 'exec "normal \<Plug>(coc-format-selected)"' ],
            \ [ "&info", 'CocInfo' ],
            \ [ "inst&all", 'exec "noraml \<Plug>(coc-install)"' ],
            \ [ "lis&t", ':CocList' ],
            \ [ "log", ':CocOpenLog' ],
            \ [ "outline", ':CocList outline' ],
            \ [ "rename", 'exec "noraml \<Plug>(coc-rename)"' ],
            \ [ "restart", 'CocRestart' ],
            \ [ "references", 'exec "noraml \<Plug>(coc-references)"' ],
            \ [ "type-definition", 'exec "noraml \<Plug>(coc-type-definition)"' ],
            \ ], 5003)

"gsettings get org.gtk.Settings.Debug enable-inspector-keybinding
"gsettings reset com.github.linarcx.giti directories
