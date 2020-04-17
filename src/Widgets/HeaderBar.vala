public class giti.HeaderBar : Gtk.HeaderBar {

    string[] m_dirs = {} ;
    public File m_repo_path { get ; set ; }
    public Ggit.Repository m_repo { get ; set ; }
    public giti.Window main_window { get ; construct ; }
    public giti.GridStaged m_staged { get ; construct ; }
    public giti.GridUntracked m_untracked { get ; construct ; }

    enum Column {
        DIRNAME
    }
    public Gtk.ListStore liststore ;

    public HeaderBar (giti.Window window) {
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
        // print ("You chose " + m_dirs[combo.get_active ()] + "\n") ;
        m_untracked.load_page (m_dirs[combo.get_active ()]) ;
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
                if( full_path in m_dirs ){
                    print ("Error: Repetitive directory!\n") ;
                } else {
                    print ("Hola! New directory found!\n") ;
                    m_dirs += full_path ;
                    // re-update liststore to fetch new items

                    string relative_path = get_relative_path (full_path) ;

                    Gtk.TreeIter iter ;
                    liststore.append (out iter) ;
                    liststore.set (iter, Column.DIRNAME, relative_path) ;
                }
                main_window.settings.set_strv ("directories", m_dirs) ;
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

    public void update_liststore() {
        for( int i = 0 ; i < m_dirs.length ; i++ ){
            string relative_path = get_relative_path (m_dirs[i]) ;
            Gtk.TreeIter iter ;
            liststore.append (out iter) ;
            liststore.set (iter, Column.DIRNAME, relative_path) ;
            // liststore.set (iter, Column.DIRNAME, m_dirs[i]) ;
        }
    }

    private Gtk.ModelButton new_menuitem(string label, string accels) {
        var button = new Gtk.ModelButton () ;
        button.get_child ().destroy () ;
        button.add (new Granite.AccelLabel (label, accels)) ;
        return button ;
    }

    construct {
        // fetch settings
        m_dirs = main_window.settings.get_strv ("directories") ;
        set_show_close_button (true) ;

        Gtk.Button add_button = new Gtk.Button () ;
        Gtk.Image add_button_img = new Gtk.Image.from_icon_name ("folder-new", Gtk.IconSize.LARGE_TOOLBAR) ;
        // add_button.get_style_context ().add_class ("suggested-action") ;
        add_button.valign = Gtk.Align.CENTER ;
        add_button.set_image (add_button_img) ;
        add_button.set_relief (Gtk.ReliefStyle.NONE) ;
        add_button.set_tooltip_markup ("Add new .git directory") ;
        add_button.clicked.connect (add_activated) ;
        pack_start (add_button) ;

        liststore = new Gtk.ListStore (1, typeof (string)) ;
        update_liststore () ;
        Gtk.ComboBox combobox = new Gtk.ComboBox.with_model (liststore) ;
        Gtk.CellRendererText cell = new Gtk.CellRendererText () ;
        combobox.pack_start (cell, false) ;
        combobox.set_attributes (cell, "text", Column.DIRNAME) ;
        combobox.set_active (0) ;
        combobox.changed.connect (this.item_changed) ;
        combobox.valign = Gtk.Align.CENTER ;
        pack_start (combobox) ;


        var new_window_item = new_menuitem ("New Window", "<Control>n") ;
        // new_window_item.action_name = Sequeler.Services.ActionManager.ACTION_PREFIX + Sequeler.Services.ActionManager.ACTION_NEW_WINDOW ;

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

        var gtk_settings = Gtk.Settings.get_default () ;
        var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic") ;
        mode_switch.primary_icon_tooltip_text = "Light background" ;
        mode_switch.secondary_icon_tooltip_text = "Dark background" ;
        mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme") ;
        mode_switch.valign = Gtk.Align.CENTER ;
        pack_end (mode_switch) ;

        var stackSwitcher = new Gtk.StackSwitcher () ;
        stackSwitcher.stack = main_window.stack ;
        set_custom_title (stackSwitcher) ;

        // setup libgit
        Ggit.init () ;
        m_repo_path = File.new_for_path (m_dirs[combobox.get_active ()]) ;
        try {
            m_repo = Ggit.Repository.open (m_repo_path) ;
            // print (m_repo_path.get_basename () + "\n") ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }

        m_untracked = new giti.GridUntracked (main_window, m_repo) ;
        m_staged = new giti.GridStaged (main_window, m_repo) ;
    }
}
