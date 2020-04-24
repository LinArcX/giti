public class GITI.GridUntracked : Gtk.Grid {

    enum Column {
        ID,
        FILE
    }

    public GITI.Window main_window { get ; construct ; }
    public Ggit.Repository _new_repo { get ; set ; }
    public Ggit.Repository init_repo { get ; construct ; }

    private string _new_full_path ;
    private Gtk.Grid grid ;
    private Gtk.TreeView _tree_view ;
    private Gtk.ListStore _list_store ;
    private Gtk.ActionBar actionbar_footer ;
    private Gtk.ScrolledWindow scrolled_window ;
    Gee.ArrayList<string> _untracked_files = new Gee.ArrayList<string> () ;

    public GridUntracked (GITI.Window window, Ggit.Repository repo) {
        GLib.Object (
            main_window: window,
            init_repo: repo
            ) ;
    }

    private int check_status_for_each_file(string file_name, Ggit.StatusFlags status) {
        if( status == Ggit.StatusFlags.WORKING_TREE_NEW
            || status == Ggit.StatusFlags.WORKING_TREE_MODIFIED ){
            _untracked_files.add (file_name) ;
        }
        return 0 ;
    }

    private void save_stash_changes() {
        Ggit.Index index ;
        index = _new_repo.get_index () ;

        for( int i = 0 ; i < _untracked_files.size ; i++ ){
            try {
                File file_untracked = File.new_for_path (_new_full_path + "/" + _untracked_files[i]) ;

                index.add_file (file_untracked) ;
                index.write () ;

                _untracked_files.clear () ;
                update_list_model_tree_view () ;
            } catch ( GLib.Error e ) {
                critical ("Error git-status: %s", e.message) ;
            }
        }
    }

    public void load_page(string path) {
        _untracked_files.clear () ;
        _new_full_path = path ;

        File new_repo_path = File.new_for_path (_new_full_path) ;
        try {
            _new_repo = Ggit.Repository.open (new_repo_path) ;
            _new_repo.file_status_foreach (null, check_status_for_each_file) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }

        update_list_model_tree_view () ;
    }

    void setup_treeview() {
        update_list_model_tree_view () ;

        _list_store = new Gtk.ListStore (2, typeof (int), typeof (string)) ;
        Gtk.TreeViewColumn col_id = new Gtk.TreeViewColumn.with_attributes ("ID", new Gtk.CellRendererText (), "text", Column.ID, null) ;
        col_id.set_clickable (true) ;
        col_id.set_fixed_width (30) ;
        col_id.set_min_width (30) ;
        col_id.set_max_width (30) ;

        var col_file = new Gtk.TreeViewColumn.with_attributes ("File", new Gtk.CellRendererText (), "text", Column.FILE, null) ;
        Gtk.Label m_label = new Gtk.Label.with_mnemonic ("File") ;
        m_label.set_visible (true) ;
        col_file.set_clickable (true) ;
        col_file.set_alignment (0.5f) ;
        col_file.set_widget (m_label) ;

        _tree_view.insert_column (col_id, -1) ;
        _tree_view.insert_column (col_file, -1) ;
    }

    private void setup_action_bar() {
        actionbar_footer = new Gtk.ActionBar () ;
        Gtk.Button btn_add = new Gtk.Button () ;
        Gtk.Image btn_add_img = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.MENU) ;

        btn_add.set_image (btn_add_img) ;
        btn_add.set_relief (Gtk.ReliefStyle.NONE) ;
        btn_add.set_tooltip_markup ("add") ;
        btn_add.clicked.connect (save_stash_changes) ;

        actionbar_footer.height_request = 30 ;
        actionbar_footer.pack_end (btn_add) ;
    }

    private void setup_scrolled_window() {
        scrolled_window = new Gtk.ScrolledWindow (null, null) ;
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC) ;
        scrolled_window.set_border_width (10) ;
        scrolled_window.add (_tree_view) ;
    }

    private void setup_grid() {
        grid = new Gtk.Grid () ;
        grid.attach (scrolled_window, 0, 0, 1, 1) ;
        grid.attach (actionbar_footer, 0, 1, 1, 50) ;
    }

    private void setup_grid_in_stack() {
        main_window._stack.add_titled (grid, "untracked", "Untracked") ;
        main_window._stack.set_focus_child.connect ((e) => {
            load_page (_new_full_path) ;
            // print (main_window.stack.get_visible_child_name ()) ;
        }) ;
    }

    public void update_list_model_tree_view() {
        _list_store.clear () ;

        Gtk.TreeIter iter ;
        for( int i = 0 ; i < _untracked_files.size ; i++ ){
            _list_store.append (out iter) ;
            _list_store.set (iter, Column.ID, i, Column.FILE, _untracked_files[i]) ;
        }

        _tree_view.set_model (_list_store) ;
    }

    construct {
        try {
            init_repo.file_status_foreach (null, check_status_for_each_file) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-status: %s", e.message) ;
        }
        _tree_view = new Gtk.TreeView () ;
        _tree_view.expand = true ;
        setup_treeview () ;

        setup_action_bar () ;
        setup_scrolled_window () ;
        setup_grid () ;
        setup_grid_in_stack () ;

        update_list_model_tree_view () ;
    }
}
