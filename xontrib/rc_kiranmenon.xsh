

# ------------------------------------------------------------------------------
# Temporary fixes of known issues
# ------------------------------------------------------------------------------

# https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1696
__import__('warnings').filterwarnings('ignore', 'There is no current event loop', DeprecationWarning, 'prompt_toolkit')


from shutil import which as _which
from xonsh.platform import ON_LINUX, ON_DARWIN

X = __xonsh__

# Try `echo $dt`.
$dt = type('TimeCl', (object,), {'__repr__':lambda self: X.imp.datetime.datetime.now().isoformat() })()

if $XONSH_INTERACTIVE:
    
    if X.env.get('XONTRIB_RC_AWESOME_SHELL_TYPE_CHECK', True) and $SHELL_TYPE not in ['prompt_toolkit', 'none', 'best']:
        printx("{YELLOW}xontrib-rc-awesome: Recommend to use prompt_toolkit shell by installing `xonsh[full]` package.{RESET}")

    # The SQLite history backend:
    # * Saves command immediately unlike JSON backend.
    # * Allows to do `history pull` to get commands from another parallel session.
    $XONSH_HISTORY_BACKEND = 'sqlite'

    # What commands are saved to the history list. By default all commands are saved. 
    # * The option ‘ignoredups’ will not save the command if it matches the previous command.
    # * The option `erasedups` will remove all previous commands that matches and updates the command frequency. 
    #   The minus of `erasedups` is that the history of every session becomes unrepeatable 
    #   because it will have a lack of the command you repeat in another session.
    # Docs: https://xonsh.github.io/envvars.html#histcontrol
    $HISTCONTROL = 'ignoredups'

    # Adding aliases from dict.
    aliases |= {
        # cd-ing shortcuts.
        '-': 'cd -',
        '~': 'cd ~',

        # Execute python that used to run current xonsh session.
        'xpython': X.imp.sys.executable,

        # List all files: sorted, with colors.
        'll': "$LC_COLLATE='C' ls -lAh --color @($args)",
        
        # Make directory and cd into it.
        # Example: md /tmp/my/awesome/dir/will/be/here
        'md': 'mkdir -p $arg0 && cd $arg0',

        # Run http server in the current directory.
        'http-here': 'python3 -m http.server',
        
        # update pip and xonsh
        'xonsh-update': 'xpip install -U pip && xpip install -U --force-reinstall git+https://github.com/xonsh/xonsh',
    }
    # my custom aliases
    aliases ['ssh-my-raspi-01'] = 'ssh pi@raspberrypi.local'

    # Easy way to go back cd-ing.
    # Example: `..` the same as `cd ../../`
    @aliases.register(".")
    @aliases.register("..")
    @aliases.register("...")
    @aliases.register("....")
    def _alias_superdot():
        """Easy way to go back cd-ing."""
        cd @("../" * len($__ALIAS_NAME))
                         
    
    # Alias to get Xonsh Context.
    # Read more: https://github.com/anki-code/xonsh-cheatsheet/blob/main/README.md#install-xonsh-with-package-and-environment-management-system
    @aliases.register("xc")
    def _alias_xc():
        """Get xonsh context."""    
        print('xpython:', X.imp.sys.executable, '#', $(xpython -V).strip())
        print('xpip:', $(which xpip).strip())  # xpip - xonsh's builtin to install packages in current session xonsh environment.
        print('')
        print('xonsh:', $(which xonsh))
        print('python:', $(which python), '#' ,$(python -V).strip())
        print('pip:', $(which pip))
        if _which('pytest'):
            print('pytest:', $(which pytest))
        print('')
        envs = ['CONDA_DEFAULT_ENV']
        for ev in envs:
            if (val := X.env.get(ev)):
                print(f'{ev}:', val)
        
    if _which('git'):
        @aliases.register('git-code-backup')
        def _git_code_bkp(args):
            paths = args if args else [$PWD]
            for p in paths:
                print(f'git code commit and push at {p}')
                with X.imp.xonsh.tools.chdir(p):
                    git status
                    git add .
                    git commit -m "code backup"
                    git push

    # myip - get my external IP address
    if _which('curl'):
        aliases['myip'] = 'curl @($args) -s https://ifconfig.co/json' + (' | jq' if _which('jq') else '')
    

    # Avoid typing cd just directory path. 
    # Docs: https://xonsh.github.io/envvars.html#auto-cd
    $AUTO_CD = True

    if ON_LINUX:
        _xontribs_to_load = (
            'dalias',             # Library of decorator aliases (daliases) e.g. `$(@json echo '{}')` or `$(@lines ls)`.
            'jump_to_dir',        # Jump to used before directory by part of the path. Lightweight zero-dependency implementation of autojump or zoxide projects functionality. 
            'prompt_bar',         # The bar prompt for xonsh shell with customizable sections. URL: https://github.com/anki-code/xontrib-prompt-bar
            'whole_word_jumping', # Jumping across whole words (non-whitespace) with Ctrl+Left/Right and Alt+Left/Right on Linux or Option+Left/Right on macOS.
            'back2dir',           # Back to the latest used directory when starting xonsh shell. URL: https://github.com/anki-code/xontrib-back2dir
            'pipeliner',          # Let your pipe lines flow thru the Python code. URL: https://github.com/anki-code/xontrib-pipeliner
            'cmd_done',           # Show long running commands durations in prompt with option to send notification when terminal is not focused. URL: https://github.com/jnoortheen/xontrib-cmd-durations
            'jedi',               # Jedi - an awesome autocompletion, static analysis and refactoring library for Python. URL: https://github.com/xonsh/xontrib-jedi
            'clp',                # Copy output to clipboard. URL: https://github.com/anki-code/xontrib-clp
        )
    elif ON_DARWIN:
        _xontribs_to_load = (
            'dalias',             # Library of decorator aliases (daliases) e.g. `$(@json echo '{}')` or `$(@lines ls)`.
            'jump_to_dir',        # Jump to used before directory by part of the path. Lightweight zero-dependency implementation of autojump or zoxide projects functionality. 
            'prompt_bar',         # The bar prompt for xonsh shell with customizable sections. URL: https://github.com/anki-code/xontrib-prompt-bar
            'back2dir',           # Back to the latest used directory when starting xonsh shell. URL: https://github.com/anki-code/xontrib-back2dir
            'pipeliner',          # Let your pipe lines flow thru the Python code. URL: https://github.com/anki-code/xontrib-pipeliner
            'cmd_done',           # Show long running commands durations in prompt with option to send notification when terminal is not focused. URL: https://github.com/jnoortheen/xontrib-cmd-durations
            'jedi',               # Jedi - an awesome autocompletion, static analysis and refactoring library for Python. URL: https://github.com/xonsh/xontrib-jedi
            'homebrew',           # https://github.com/eugenesvk/xontrib-homebrew
        )
    xontrib load -s @(_xontribs_to_load)

    #
    # Example of binding the hotkeys - https://xon.sh/tutorial_ptk.html
    # List of keys - https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/src/prompt_toolkit/keys.py
    # `event.current_buffer` - https://python-prompt-toolkit.readthedocs.io/en/stable/pages/reference.html#prompt_toolkit.buffer.Buffer
    #
    @events.on_ptk_create
    def custom_keybindings(bindings, **kw):

        # Press F1 and get the list of files
        @bindings.add(__xonsh__.imp.prompt_toolkit.keys.Keys.F1)
        def run_ls(event):
            ls -l
            event.cli.renderer.erase()

        # Press F3 to insert the grep command
        @bindings.add(__xonsh__.imp.prompt_toolkit.keys.Keys.F3)
        def add_grep(event):
            event.current_buffer.insert_text(' | grep -i ')     
       

    $XONSH_COLOR_STYLE = 'monokai'            

    # source local xonshrc file if present
    local_rc = X.imp.os.path.expanduser("~/.xonshrc_local.xsh")
    if X.imp.os.path.exists(local_rc):
        source @(local_rc)
