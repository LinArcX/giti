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

public class GITI.HeaderBar : Gtk.HeaderBar {

    enum Column {
        DIRNAME
    }

    // string[, ] _titles_and_full_paths = { {} } ;
    string[] _paths = {} ;
    Gee.ArrayList<Gee.ArrayList<string> > _titles_and_full_paths ;

    public Gtk.ListStore _list_store ;
    public string full_path_except_project_name ;

    public File tt_current_repo_path { get ; set ; }
    public Ggit.Repository t_current_repo { get ; set ; }
    private Gtk.ComboBox t_cb_directories { get ; set ; }

    public GITI.Window main_window { get ; construct ; }
    public GITI.GridStaged t_grid_staged { get ; set ; }
    public GITI.GridUntracked t_grid_untracked { get ; set ; }

    public Ggit.Config _git_config ;

    public static string _user_name ;
    public static string _user_email ;

    public HeaderBar (GITI.Window window) {
        Object (
            main_window: window
            ) ;
    }

    private string get_directory_name(string ugly) {
        string[] sub_path = ugly.split ("/") ;
        int size_sub_path = sub_path.length ;
        return sub_path[size_sub_path - 1] ;
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

                if( full_path in _paths ){
                    print ("Error: Repetitive directory!\n") ;
                } else {
                    print ("Hola! New directory found!\n") ;

                    // update gsettings
                    _paths += full_path ;
                    main_window._settings.set_strv ("directories", _paths) ;

                    // update liststore to show new directory
                    string directory_name = get_directory_name (full_path) ;
                    Gtk.TreeIter iter ;
                    _list_store.append (out iter) ;
                    _list_store.set (iter, Column.DIRNAME, directory_name) ;
                }
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

    public void add_activated() {
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

    private void get_directories_and_make_array_2d() {
        _paths = main_window._settings.get_strv ("directories") ;
        _titles_and_full_paths = new Gee.ArrayList<Gee.ArrayList<string> >() ;
        var internal = new Gee.ArrayList<string>() ;

        for( int i = 0 ; i < _paths.length ; i++ ){
            string[] path_splitted = _paths[i].split ("/") ;
            int size_path_splitted = path_splitted.length ;
            string title = path_splitted[size_path_splitted - 1] ;
            internal.add (title) ;
            internal.add (_paths[i]) ;

        }
        _titles_and_full_paths.add (internal) ;
    }

    private void setup_btn_add_new_folder() {
        Gtk.Button btn_add = new Gtk.Button () ;
        Gtk.Image btn_add_img = new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR) ;
        btn_add.valign = Gtk.Align.CENTER ;
        btn_add.set_image (btn_add_img) ;
        btn_add.set_relief (Gtk.ReliefStyle.NONE) ;
        btn_add.set_tooltip_markup ("Add new directory") ;
        btn_add.clicked.connect (add_activated) ;
        pack_start (btn_add) ;
    }

    private Gtk.ModelButton new_menuitem(string label, string accels) {
        var button = new Gtk.ModelButton () ;
        button.get_child ().destroy () ;
        button.add (new Granite.AccelLabel (label, accels)) ;
        return button ;
    }

    private void setup_menu_items() {
        var preferences_menu_item = new_menuitem ("Preferences", "<Control>p") ;
        preferences_menu_item.action_name = GITI.Window.ACTION_PREFIX + GITI.Window.ACTION_PREFERENCES ;

        var about_menu_item = new_menuitem ("About", "F1") ;
        about_menu_item.action_name = GITI.Window.ACTION_PREFIX + GITI.Window.ACTION_ABOUT ;

        var quit_menu_item = new_menuitem ("Close Applicatoin", "<Control>q") ;
        quit_menu_item.action_name = GITI.Window.ACTION_PREFIX + GITI.Window.ACTION_QUIT ;

        var menu_grid = new Gtk.Grid () ;
        menu_grid.expand = true ;
        menu_grid.margin_top = menu_grid.margin_bottom = 6 ;
        menu_grid.orientation = Gtk.Orientation.VERTICAL ;

        menu_grid.attach (preferences_menu_item, 0, 1, 1, 1) ;
        menu_grid.attach (about_menu_item, 0, 2, 1, 1) ;
        menu_grid.attach (quit_menu_item, 0, 3, 1, 1) ;
        menu_grid.show_all () ;

        var open_menu = new Gtk.MenuButton () ;
        open_menu.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR)) ;
        open_menu.tooltip_text = "Menu" ;

        Gtk.Popover menu_popover = new Gtk.Popover (open_menu) ;
        menu_popover.add (menu_grid) ;

        open_menu.popover = menu_popover ;
        open_menu.valign = Gtk.Align.CENTER ;
        pack_end (open_menu) ;
    }

    public void update_liststore() {
        for( int i = 0 ; i < _paths.length ; i++ ){
            string directory_name = get_directory_name (_paths[i]) ;
            Gtk.TreeIter iter ;
            _list_store.append (out iter) ;
            _list_store.set (iter, Column.DIRNAME, directory_name) ;
        }
    }

    private void fetch_git_config() {
        try {
            _git_config = new Ggit.Config.default () ;
            _user_name = _git_config.get_entry ("user.name").get_value () ;
            _user_email = _git_config.get_entry ("user.email").get_value () ;
        } catch ( GLib.Error e ) {
            critical ("Error git (get configs): %s", e.message) ;
        }

    }

    void item_changed(Gtk.ComboBox combo) {
        t_grid_untracked.load_page (_paths[combo.get_active ()]) ;
        t_grid_staged.load_page (_paths[combo.get_active ()]) ;
    }

    private void setupt_cb_directories() {
        _list_store = new Gtk.ListStore (1, typeof (string)) ;
        update_liststore () ;
        t_cb_directories = new Gtk.ComboBox.with_model (_list_store) ;
        Gtk.CellRendererText cell = new Gtk.CellRendererText () ;
        t_cb_directories.pack_start (cell, false) ;
        t_cb_directories.set_attributes (cell, "text", Column.DIRNAME) ;
        t_cb_directories.set_active (0) ;
        t_cb_directories.changed.connect (this.item_changed) ;
        t_cb_directories.valign = Gtk.Align.CENTER ;
        pack_start (t_cb_directories) ;
    }

    private void setup_granite_switch() {
        var gtk_settings = Gtk.Settings.get_default () ;
        var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic") ;
        mode_switch.primary_icon_tooltip_text = "Light background" ;
        mode_switch.secondary_icon_tooltip_text = "Dark background" ;
        mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme") ;
        mode_switch.valign = Gtk.Align.CENTER ;
        pack_end (mode_switch) ;
    }

    private void setupt_stack_switcher() {
        var stackSwitcher = new Gtk.StackSwitcher () ;
        stackSwitcher.stack = main_window.t_stack ;
        set_custom_title (stackSwitcher) ;
    }

    private void setup_libgit() {
        Ggit.init () ;
        tt_current_repo_path = File.new_for_path (_paths[t_cb_directories.get_active ()]) ;
        try {
            t_current_repo = Ggit.Repository.open (tt_current_repo_path) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }
    }

    private void setup_grid_items() {
        t_grid_untracked = new GITI.GridUntracked (main_window, t_current_repo) ;
        t_grid_staged = new GITI.GridStaged (main_window, t_current_repo) ;
    }

    construct {
        set_show_close_button (true) ;
        get_directories_and_make_array_2d () ;

        setup_btn_add_new_folder () ;
        setup_menu_items () ;
        setupt_cb_directories () ;
        setup_granite_switch () ;
        setupt_stack_switcher () ;

        setup_libgit () ;
        fetch_git_config () ;

        setup_grid_items () ;
    }
}
