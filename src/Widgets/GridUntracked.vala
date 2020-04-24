public class GITI.GridUntracked : Gtk.Grid {

    public GITI.Window main_window { get ; construct ; }
    public Ggit.Repository m_repo { get ; construct ; }
    public Ggit.Repository p_repo { get ; set ; }
    string _full_path ;

    Gee.ArrayList<string> list_untracked = new Gee.ArrayList<string> () ;

    Gtk.ListStore listmodel ;
    Gtk.TreeView view ;

    enum Column {
        ID,
        FILE
    }

    public GridUntracked (GITI.Window window, Ggit.Repository repo) {
        GLib.Object (
            main_window: window,
            m_repo: repo
            ) ;
    }

    public void re_create() {

        listmodel.clear () ;

        /* Insert the phonebook into the ListStore */
        Gtk.TreeIter iter ;
        for( int i = 0 ; i < list_untracked.size ; i++ ){
            listmodel.append (out iter) ;
            listmodel.set (iter, Column.ID, i, Column.FILE, list_untracked[i]) ;
        }
        view.set_model (listmodel) ;
    }

    void setup_treeview() {
        re_create () ;

        listmodel = new Gtk.ListStore (2, typeof (int), typeof (string)) ;
        /*columns*/
        Gtk.TreeViewColumn col_id = new Gtk.TreeViewColumn.with_attributes ("ID", new Gtk.CellRendererText (), "text", Column.ID, null) ;
        col_id.set_clickable (true) ;
        col_id.set_fixed_width (30) ;
        col_id.set_min_width (30) ;
        col_id.set_max_width (30) ;
        view.insert_column (col_id, -1) ;

        var col_file = new Gtk.TreeViewColumn.with_attributes ("File", new Gtk.CellRendererText (), "text", Column.FILE, null) ;
        col_file.set_clickable (true) ;

        Gtk.Label m_label = new Gtk.Label.with_mnemonic ("File") ;
        m_label.set_visible (true) ;
        // m_label.set_size_request (200, -1) ;
        col_file.set_alignment (0.5f) ;
        col_file.set_widget (m_label) ;
        view.insert_column (col_file, -1) ;
    }

    private int check_each_git_status(string path, Ggit.StatusFlags status) {
        if( status == Ggit.StatusFlags.WORKING_TREE_NEW || status == Ggit.StatusFlags.WORKING_TREE_MODIFIED ){
            list_untracked.add (path) ;
            // print (path + ": " + status.to_string () + "\n") ;
        }
        return 0 ;
    }

    public void load_page(string path) {
        list_untracked.clear () ;
        _full_path = path ;

        File p_repo_path = File.new_for_path (path) ;
        try {
            p_repo = Ggit.Repository.open (p_repo_path) ;
            p_repo.file_status_foreach (null, check_each_git_status) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }

        re_create () ;
    }

    private void save_stash_changes() {
        Ggit.Index index ;
        index = p_repo.get_index () ;

        for( int i = 0 ; i < list_untracked.size ; i++ ){
            try {
                File file_untracked = File.new_for_path (_full_path + "/" + list_untracked[i]) ;

                index.add_file (file_untracked) ;
                index.write () ;

                list_untracked.clear () ;
                re_create () ;
            } catch ( GLib.Error e ) {
                critical ("Error git-status: %s", e.message) ;
            }
        }
    }

    construct {
        try {
            m_repo.file_status_foreach (null, check_each_git_status) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-status: %s", e.message) ;
        }

        var grid = new Gtk.Grid () ;
        view = new Gtk.TreeView () ;

        this.setup_treeview () ;
        view.expand = true ;

        Gtk.Button btn_add = new Gtk.Button () ;
        Gtk.Image btn_add_img = new Gtk.Image.from_icon_name ("document-export", Gtk.IconSize.MENU) ;
        btn_add.set_image (btn_add_img) ;
        btn_add.set_relief (Gtk.ReliefStyle.NONE) ;
        btn_add.set_tooltip_markup ("add") ;

        btn_add.clicked.connect (save_stash_changes) ;

        Gtk.ActionBar actionbar_footer = new Gtk.ActionBar () ;
        actionbar_footer.pack_end (btn_add) ;
        actionbar_footer.height_request = 30 ;

        var scrolled_window = new Gtk.ScrolledWindow (null, null) ;
        scrolled_window.set_border_width (10) ;
        scrolled_window.add (view) ;
        scrolled_window.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC) ;

        grid.attach (scrolled_window, 0, 0, 1, 1) ;
        grid.attach (actionbar_footer, 0, 1, 1, 50) ;

        main_window._stack.add_titled (grid, "untracked", "Untracked") ;
        main_window._stack.set_focus_child.connect ((e) => {
            // print (main_window.stack.get_visible_child_name ()) ;
        }) ;
        re_create () ;
    }
}

// Emitted when the button has been activated:
// Ggit.Index index = new Ggit.Index () ;
// index.add () ;
// try {
// Ggit.Signature sig = new Ggit.Signature.now ("linarch", "linarcx@riseup.net") ;
// m_repo.save_stash (sig, "message", Ggit.StashFlags.DEFAULT) ;
// } catch ( GLib.Error e ) {
// critical ("Error git-repo open: %s", e.message) ;
// }
// for( int i = 0 ; i < list_untracked.size ; i++ ){
// print (list_untracked[i] + "\n") ;
// }



// Ggit.Signature sig = new Ggit.Signature.now ("linarcx", "linarcx@riseup.net") ;
// Gitg.Stage.stage() stg = new Gitg.Stage () ;

// Gitg.Stage stg ; // = new Gitg.Stage () ;
// stg = this ;
// stg.stage (file_untracked) ;
// stg.stage (list_untracked[i]) ;
// p_repo.save_stash (sig, "message", Ggit.StashFlags.KEEP_INDEX) ;


// Gtk.Widget wid = main_window.stack.get_child_by_name ("untracked") ;
// Gtk.Widget wid = main_window.stack.get_visible_child () ;
// e.visible = false ;
// print (e.name + "\n") ;
// print (e.get_tooltip_text () + "\n") ;
// print (e.get_tooltip_markup () + "\n") ;

// main_window.stack.screen_changed.connect (() => {
// print ("hi" + "\n") ;
// }) ;


// unowned ParamSpec ? spec = main_window.stack.find_property ("visible_child") ;

// main_window.stack.notify.connect ((spec) => {
// print ("hi" + "\n") ;
// print (spec.get_nick ()) ;
// }) ;


// btn_add.clicked.connect (() => {
// print ("In..") ;
// }) ;
