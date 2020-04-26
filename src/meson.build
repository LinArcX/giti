executable(
    meson.project_name(),

    'Main.vala',
    'Application.vala',

    'Widgets/Window.vala',
    'Widgets/WelcomePage.vala',
    'Widgets/WelcomeHeaderBar.vala',
    'Widgets/HeaderBar.vala',
    'Widgets/GridUntracked.vala',
    'Widgets/GridStaged.vala',
    'Util/Util.vala',
    'Util/AsyncStatus.vala',

    dependencies: [
        dependency('gtk+-3.0'),
        dependency('libgit2-glib-1.0'),
        dependency('gee-0.8'),
        dependency('granite')
    ],

    install: true
)
