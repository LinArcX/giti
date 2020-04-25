/*
 * Copyright 2020 - LinArcX, <linarcx@riseup.net>
 * This file is part of giti.
 *
 * giti is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * giti is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with giti. If not, see <http://www.gnu.org/licenses/>.
 *
 */

public class GITI.WelcomePage : Gtk.Grid {

    public GITI.Window main_window { get ; construct ; }
    public Granite.Widgets.Welcome welcome_widget { get ; construct ; }

    public WelcomePage (GITI.Window window) {
        Object (
            main_window: window
            ) ;
    }

    private void update_screen(string first_directory_path) {
        remove (main_window._welcome_page) ;

        main_window.remove (this) ;
        this.destroy () ;
        main_window.remove (main_window._welcome_header_bar) ;
        main_window._welcome_header_bar.destroy () ;

        string[] m_dirs = {} ;
        m_dirs += first_directory_path ;
        main_window._settings.set_strv ("directories", m_dirs) ;
        main_window.add (main_window._stack) ;
        main_window._main_header_bar = new GITI.HeaderBar (main_window) ;
        main_window.set_titlebar (main_window._main_header_bar) ;
        main_window.show_all () ;
        show_all () ;
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
                update_screen (full_path) ;
            } else {
                GITI.Util.show_notification (main_window.app, full_path, "This isn't a git directory!") ;
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
        welcome_widget = new Granite.Widgets.Welcome ("Welcome to Giti", "Permanent observer of your git directories.") ;
        welcome_widget.append ("folder-new", "Add new directory", "Start your journey by adding first directory.") ;
        welcome_widget.append ("text-x-source", "Get Giti Source", "Giti's source code is hosted on GitHub.") ;
        add (welcome_widget) ;

        welcome_widget.activated.connect ((index) => {
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
