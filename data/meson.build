icon_sizes = ['16', '24', '32', '48', '64', '128']

icons_dir = join_paths(get_option('datadir'), 'icons', 'hicolor')
foreach size : icon_sizes
		asset = join_paths('assets', 'icons', '@0@x@0@'.format(size), '@0@.svg'.format(meson.project_name()))
		install_data(
				asset,
				install_dir:  join_paths(icons_dir, '@0@x@0@'.format(size), 'apps'),
				rename: '@0@.svg'.format(meson.project_name())
		)
		install_data(
				asset,
				install_dir: join_paths(icons_dir,  '@0@x@0@@2'.format(size), 'apps'),
				rename: '@0@.svg'.format(meson.project_name())
		)
endforeach

install_data(
		join_paths('assets', 'icons', '128x128', '@0@.svg'.format(meson.project_name())),
		install_dir: join_paths(icons_dir , 'scalable', 'apps'),
		rename: '@0@.svg'.format(meson.project_name())
)

# Install the Desktop file
desktop_conf = configuration_data()
desktop_conf.set('icon', meson.project_name())
desktop_conf.set('binary', meson.project_name())

desktop_file = i18n.merge_file(
		input: configure_file(
			input: '@0@.desktop.in.in'.format(meson.project_name()),
			output: '@0@.desktop.in'.format(meson.project_name()),
			configuration: desktop_conf
		),
		output:'@0@.desktop'.format(meson.project_name()),
		po_dir: join_paths(meson.source_root(), 'po', 'extra'),
		type: 'desktop',
		install: true,
		install_dir: join_paths(get_option('datadir'), 'applications')
)

# Validate desktop file
desktop_file_validate = find_program('desktop-file-validate', required: false)
if desktop_file_validate.found()
	test(
		'validate-desktop',
		desktop_file_validate,
		args: [
			desktop_file.full_path()
		]
	)
endif

install_data(
    'gschema.xml',
    install_dir: join_paths(get_option ('datadir'), 'glib-2.0', 'schemas'),
    rename: meson.project_name() + '.gschema.xml'
)
