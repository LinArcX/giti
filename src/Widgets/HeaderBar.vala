public class giti.HeaderBar : Gtk.HeaderBar {

    public File m_repo_path { get ; set ; }
    public Ggit.Repository m_repo { get ; set ; }
    public giti.GridStaged m_staged { get ; construct ; }
    public giti.GridUntracked m_untracked { get ; construct ; }


    string[] m_dirs = {} ;
    public giti.Window main_window { get ; construct ; }
    enum Column {
        DIRNAME
    }
    public Gtk.ListStore liststore ;

    public HeaderBar (giti.Window window) {
        Object (
            main_window: window
            ) ;
    }

    void item_changed(Gtk.ComboBox combo) {
        print ("You chose " + m_dirs[combo.get_active ()] + "\n") ;
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

                    Gtk.TreeIter iter ;
                    liststore.append (out iter) ;
                    liststore.set (iter, Column.DIRNAME, full_path) ;
                }
                main_window.settings.set_strv ("directories", m_dirs) ;
            } else {
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
            Gtk.TreeIter iter ;
            liststore.append (out iter) ;
            liststore.set (iter, Column.DIRNAME, m_dirs[i]) ;
        }
    }

    construct {
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

        var menu_button = new Gtk.Button.from_icon_name ("open-menu",
                                                         Gtk.IconSize.LARGE_TOOLBAR) ;
        menu_button.valign = Gtk.Align.CENTER ;
        pack_end (menu_button) ;

        var stackSwitcher = new Gtk.StackSwitcher () ;
        stackSwitcher.stack = main_window.stack ;
        set_custom_title (stackSwitcher) ;


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
