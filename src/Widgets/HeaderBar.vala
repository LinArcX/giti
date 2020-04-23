public class GITI.HeaderBar : Gtk.HeaderBar {

    enum Column {
        DIRNAME
    }

    string[] _dirs = {} ;
    public Gtk.ListStore _list_store ;
    public string full_path_except_project_name ;

    public File _current_repo_path { get ; set ; }
    public Ggit.Repository _current_repo { get ; set ; }
    private Gtk.ComboBox _cb_directories { get ; set ; }

    public GITI.Window main_window { get ; construct ; }
    public GITI.GridStaged _grid_staged { get ; set ; }
    public GITI.GridUntracked _grid_untracked { get ; set ; }

    public HeaderBar (GITI.Window window) {
        Object (
            main_window: window
            ) ;
    }

    private string get_relative_path(string ugly) {
        string[] sub_path = ugly.split ("/") ;
        int size_sub_path = sub_path.length ;
        string project_name = sub_path[size_sub_path - 1] ;
        // string parent_directory = sub_path[size_sub_path - 2] ;
        // string relative_path = parent_directory + "/" + project_name ;
        string relative_path = project_name ;
        return relative_path ;
    }

    void item_changed(Gtk.ComboBox combo) {
        // print ("You chose " + _dirs[combo.get_active ()] + "\n") ;
        _grid_untracked.load_page (_dirs[combo.get_active ()]) ;
        _grid_staged.load_page (_dirs[combo.get_active ()]) ;
    }

    private void dir_selected(Gtk.NativeDialog dialog, int response_id) {
        var open_dialog = dialog as Gtk.FileChooserNative ;

        switch( response_id ){
        case Gtk.ResponseType.ACCEPT:
            var file = open_dialog.get_file () ;
            var full_path = file.get_path () ;

            File git_path = File.new_for_path (full_path + "/.git") ;
            bool is_git = git_path.query_exists () ;
            if( is_git == true ){
                print ("This is a git directory.\n") ;
                if( full_path in _dirs ){
                    print ("Error: Repetitive directory!\n") ;
                } else {
                    print ("Hola! New directory found!\n") ;
                    _dirs += full_path ;
                    // re-update liststore to fetch new items

                    string relative_path = get_relative_path (full_path) ;

                    Gtk.TreeIter iter ;
                    _list_store.append (out iter) ;
                    // _list_store.set (iter, Column.DIRNAME, relative_path) ;
                    _list_store.set (iter, Column.DIRNAME, full_path) ;
                }
                main_window._settings.set_strv ("directories", _dirs) ;
            } else {
                GITI.Util.show_notification (main_window.app, full_path,
                                             "com.github.linarcx.giti",
                                             "This isn't a git directory!",
                                             "dialog-warning") ;
            }
            break ;
        case Gtk.ResponseType.CANCEL:
            open_dialog.destroy () ;
            break ;
        }
        open_dialog.destroy () ;
    }

    public void add_activated() {
        var open_dialog = new Gtk.FileChooserNative ("Select a file",
                                                     main_window,
                                                     Gtk.FileChooserAction.SELECT_FOLDER,
                                                     "_Open",
                                                     "_Cancel") ;
        open_dialog.local_only = true ;
        open_dialog.modal = true ;
        open_dialog.response.connect (dir_selected) ;
        open_dialog.run () ;
    }

    private void setup_grid_items() {
        _grid_untracked = new GITI.GridUntracked (main_window, _current_repo) ;
        _grid_staged = new GITI.GridStaged (main_window, _current_repo) ;
    }

    public void update_liststore() {
        for( int i = 0 ; i < _dirs.length ; i++ ){
            // string relative_path = get_relative_path (_dirs[i]) ;
            Gtk.TreeIter iter ;
            _list_store.append (out iter) ;
            _list_store.set (iter, Column.DIRNAME, _dirs[i]) ;
            // _list_store.set (iter, Column.DIRNAME, relative_path) ;
        }
    }

    private void setup_stack_switcher() {
        var stackSwitcher = new Gtk.StackSwitcher () ;
        stackSwitcher.stack = main_window._stack ;
        set_custom_title (stackSwitcher) ;
        // stackSwitcher.stack.set_focus_child.connect (() => {
        // print ("hi" + "\n") ;
        // }) ;
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

    private void setup_cb_directories() {
        _list_store = new Gtk.ListStore (1, typeof (string)) ;
        update_liststore () ;
        _cb_directories = new Gtk.ComboBox.with_model (_list_store) ;
        Gtk.CellRendererText cell = new Gtk.CellRendererText () ;
        _cb_directories.pack_start (cell, false) ;
        _cb_directories.set_attributes (cell, "text", Column.DIRNAME) ;
        _cb_directories.set_active (0) ;
        _cb_directories.changed.connect (this.item_changed) ;
        _cb_directories.valign = Gtk.Align.CENTER ;
        pack_start (_cb_directories) ;
    }

    private Gtk.ModelButton new_menuitem(string label, string accels) {
        var button = new Gtk.ModelButton () ;
        button.get_child ().destroy () ;
        button.add (new Granite.AccelLabel (label, accels)) ;
        return button ;
    }

    private void setup_menu_items() {
        var new_window_item = new_menuitem ("New Window", "<Control>n") ;

        var menu_grid = new Gtk.Grid () ;
        menu_grid.expand = true ;
        menu_grid.margin_top = menu_grid.margin_bottom = 6 ;
        menu_grid.orientation = Gtk.Orientation.VERTICAL ;

        menu_grid.attach (new_window_item, 0, 1, 1, 1) ;
        // menu_grid.attach (new_connection_item, 0, 2, 1, 1) ;
        // menu_grid.attach (menu_separator, 0, 3, 1, 1) ;
        // menu_grid.attach (quit_item, 0, 4, 1, 1) ;
        menu_grid.show_all () ;

        var open_menu = new Gtk.MenuButton () ;
        open_menu.set_image (new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR)) ;
        open_menu.tooltip_text = "Menu" ;

        // var menu_button = new Gtk.Button.from_icon_name ("open-menu",
        // Gtk.IconSize.LARGE_TOOLBAR) ;
        Gtk.Popover menu_popover = new Gtk.Popover (open_menu) ;
        menu_popover.add (menu_grid) ;

        open_menu.popover = menu_popover ;
        open_menu.valign = Gtk.Align.CENTER ;
        pack_end (open_menu) ;
    }

    private void setup_libgit() {
        Ggit.init () ;
        _current_repo_path = File.new_for_path (_dirs[_cb_directories.get_active ()]) ;
        try {
            _current_repo = Ggit.Repository.open (_current_repo_path) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }
    }

    private void setup_btn_add_new_folder() {
        Gtk.Button btn_add = new Gtk.Button () ;
        Gtk.Image btn_add_img = new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR) ;
        // btn_add.get_style_context ().add_class ("suggested-action") ;
        btn_add.valign = Gtk.Align.CENTER ;
        btn_add.set_image (btn_add_img) ;
        btn_add.set_relief (Gtk.ReliefStyle.NONE) ;
        btn_add.set_tooltip_markup ("Add new .git directory") ;
        btn_add.clicked.connect (add_activated) ;
        pack_start (btn_add) ;
    }

    construct {
        _dirs = main_window._settings.get_strv ("directories") ;
        set_show_close_button (true) ;

        setup_btn_add_new_folder () ;
        setup_menu_items () ;
        setup_cb_directories () ;
        setup_granite_switch () ;
        setup_stack_switcher () ;

        setup_libgit () ;
        setup_grid_items () ;
    }
}
