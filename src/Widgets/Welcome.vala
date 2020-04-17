public class giti.WelcomeView : Gtk.Grid {

    public giti.Window main_window { get ; construct ; }
    public Granite.Widgets.Welcome welcome { get ; construct ; }

    public WelcomeView (giti.Window window) {
        Object (
            main_window: window
            ) ;
    }

    private void dir_selected(Gtk.NativeDialog dialog, int response_id) {
        var dlg = dialog as Gtk.FileChooserNative ;

        switch( response_id ){
        case Gtk.ResponseType.ACCEPT:
            var file = dlg.get_file () ;
            var full_path = file.get_path () ;

            File git_path = File.new_for_path (full_path + "/.git") ;
            bool is_git = git_path.query_exists () ;
            if( is_git == true ){
                print ("This is a git directory.\n") ;
                remove (main_window.welcome_view) ;

                main_window.remove (this) ;
                this.destroy () ;
                main_window.remove (main_window.welcome_header_bar) ;
                main_window.welcome_header_bar.destroy () ;

                string[] m_dirs = {} ;
                m_dirs += full_path ;
                main_window.settings.set_strv ("directories", m_dirs) ;
                main_window.add (main_window.stack) ;
                main_window.main_header_bar = new giti.HeaderBar (main_window) ;
                main_window.set_titlebar (main_window.main_header_bar) ;
                main_window.show_all () ;
                show_all () ;
            } else {
                // send a system notification
                var notification = new GLib.Notification (full_path) ;
                var icon = new GLib.ThemedIcon ("dialog-warning") ;
                notification.set_body ("This isn't a git directory!") ;
                notification.set_icon (icon) ;
                main_window.m_app.send_notification ("com.github.linarcx.giti", notification) ;
            }
            break ;
        case Gtk.ResponseType.CANCEL:
            dlg.destroy () ;
            break ;
        }
        dlg.destroy () ;
    }

    public void open_dialog() {
        var dlg = new Gtk.FileChooserNative ("Select a file",
                                             main_window,
                                             Gtk.FileChooserAction.SELECT_FOLDER,
                                             "_Open",
                                             "_Cancel") ;
        dlg.local_only = true ;
        dlg.modal = true ;
        dlg.response.connect (dir_selected) ;
        dlg.run () ;
    }

    construct {
        welcome = new Granite.Widgets.Welcome ("Welcome to Giti", "Permanent observer of your git directories.") ;
        welcome.append ("folder-new", "Add new directory", "Start your journey by adding first directory.") ;
        welcome.append ("text-x-source", "Get Giti Source", "Giti's source code is hosted on GitHub.") ;
        add (welcome) ;

        welcome.activated.connect ((index) => {
            switch( index ){
            case 0:
                try {
                    open_dialog () ;
                } catch ( Error e ) {
                    warning (e.message) ;
                }

                break ;
            case 1:
                try {
                    AppInfo.launch_default_for_uri ("https://github.com/LinArcX/giti", null) ;
                } catch ( Error e ) {
                    warning (e.message) ;
                }

                break ;
            }
        }) ;
    }
}
