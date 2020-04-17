project('com.github.linarcx.giti', 'vala', 'c')

# Include the translations module
i18n = import('i18n')

add_project_arguments(
    ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
    language: 'vala'
)

subdir('src')
subdir('data')

meson.add_install_script('meson/post_install.py')
