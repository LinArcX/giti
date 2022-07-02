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

public class GITI.GridStaged : Gtk.Grid {

    enum Column {
        ID,
        FILE
    }

    public GITI.Window main_window { get ; construct ; }
    public Ggit.Repository t_new_repo { get ; set ; }
    public Ggit.Repository init_repo { get ; construct ; }

    private string _new_full_path ;
    private Gtk.Grid grid ;
    private Gtk.TreeView _tree_view ;
    private Gtk.ListStore _list_store ;
    private Gtk.ActionBar actionbar_footer ;
    private Gtk.ScrolledWindow scrolled_window ;
    Gee.ArrayList<string> _staged_files = new Gee.ArrayList<string> () ;

    public GridStaged (GITI.Window window, Ggit.Repository repo) {
        GLib.Object (
            main_window: window,
            init_repo: repo
            ) ;
    }

    private int check_status_for_each_file(string file_name, Ggit.StatusFlags status) {
        if( status == Ggit.StatusFlags.INDEX_NEW ){
            // || status == Ggit.StatusFlags.INDEX_MODIFIED
            // || status == Ggit.StatusFlags.INDEX_DELETED ){
            _staged_files.add (file_name) ;
        }
        return 0 ;
    }

    public Ggit.Signature ? get_verified_committer ()
    {
        try {
            return new Ggit.Signature.now (GITI.HeaderBar._user_name,
                                           GITI.HeaderBar._user_email) ;
        } catch ( Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
            return null ;
        }
    }

    private void commit_files(string commit_message) {
        // First stage files(by index) and then commit them.
        // Unless you have a commit, without any file including!
        Ggit.Index index ;

        if( t_new_repo == null ){
            _new_full_path = init_repo.get_workdir ().get_path () ;
            index = init_repo.get_index () ;
        } else {
            index = t_new_repo.get_index () ;
        }

        for( int i = 0 ; i < _staged_files.size ; i++ ){
            File file_staged = File.new_for_path (_new_full_path + "/" + _staged_files[i]) ;
            try {
                index.add_path (file_staged.get_basename ()) ;
            } catch ( GLib.Error e ) {
                critical ("Error git (index.add_path()): %s", e.message) ;
            }
        }

        Ggit.OId treeoid ;
        try {
            index.write () ;
            treeoid = index.write_tree () ;
        } catch ( GLib.Error e ) {
            critical ("Error git (index.write_tree()): %s", e.message) ;
            return ;
        }

        // Now you can commit the staged files
        try {
            Ggit.Tree tree ;
            Ggit.OId commitoid ;
            Ggit.Ref ? head = null ;
            Ggit.Commit ? parent = null ;
            var sig = get_verified_committer () ;

            if( t_new_repo == null ){
                head = init_repo.get_head () ;
                tree = init_repo.lookup_tree (treeoid) ;
            } else {
                head = t_new_repo.get_head () ;
                tree = t_new_repo.lookup_tree (treeoid) ;
            }

            try {
                parent = head.lookup () as Ggit.Commit ;
            } catch ( GLib.Error e ) {
                critical ("Error git (head.lookup() or repo.lookup_tree()): %s", e.message) ;
                return ;
            }

            try {
                Ggit.Commit[] parents ;
                if( parent != null ){
                    parents = new Ggit.Commit[] { parent } ;
                } else {
                    parents = new Ggit.Commit[] {} ;
                }

                for( int i = 0 ; i < _staged_files.size ; i++ ){
                    if( t_new_repo == null ){
                        commitoid = init_repo.create_commit ("HEAD", sig, sig,
                                                             null, commit_message,
                                                             tree, parents) ;
                    } else {
                        commitoid = t_new_repo.create_commit ("HEAD", sig, sig,
                                                             null, commit_message,
                                                             tree, parents) ;
                    }

                    // update list-model and tree-view
                    _staged_files.clear () ;
                    update_list_model_tree_view () ;

                    head.set_target (commitoid, "log") ;
                }
            } catch ( GLib.Error e ) {
                critical ("Error git (get-commit): %s", e.message) ;
            }

        } catch ( GLib.Error e ) {
            critical ("Error git (get-commit): %s", e.message) ;
        }
    }

    public void load_page(string path) {
        _staged_files.clear () ;
        _new_full_path = path ;

        File new_repo_path = File.new_for_path (_new_full_path) ;
        try {
            t_new_repo = Ggit.Repository.open (new_repo_path) ;
            t_new_repo.file_status_foreach (null, check_status_for_each_file) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }

        update_list_model_tree_view () ;
    }

    private void get_commit_message() {
        var commit_dialog = new Gtk.Dialog () ;

        commit_dialog.deletable = false ;
        commit_dialog.resizable = false ;
        commit_dialog.default_width = 400 ;
        commit_dialog.decorated = true ;
        commit_dialog.border_width = 8 ;

        var content_area = commit_dialog.get_content_area () ;

        var lbl_commit = new Gtk.Label ("Commit message:") ;
        lbl_commit.set_justify (Gtk.Justification.LEFT) ;
        lbl_commit.halign = Gtk.Align.START ;
        lbl_commit.valign = Gtk.Align.CENTER ;

        var txt_commit_message = new Gtk.TextView () ;
        txt_commit_message.height_request = 100 ;
        txt_commit_message.wrap_mode = Gtk.WrapMode.WORD ;

        var apply_button = new Gtk.Button.with_label (("Commit")) ;
        apply_button.width_request = 400 ;
        apply_button.halign = Gtk.Align.CENTER ;
        apply_button.get_style_context ().add_class ("suggested-action") ;
        apply_button.clicked.connect (() => {
            // print () ;
            commit_files (txt_commit_message.buffer.text) ;
            commit_dialog.close () ;
        }) ;

        content_area.pack_start (lbl_commit) ;
        content_area.pack_start (txt_commit_message) ;
        content_area.pack_start (apply_button) ;
        commit_dialog.show_all () ;
        commit_dialog.present () ;
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
        Gtk.Image btn_add_img = new Gtk.Image.from_icon_name ("document-send", Gtk.IconSize.MENU) ;

        btn_add.set_image (btn_add_img) ;
        btn_add.set_relief (Gtk.ReliefStyle.NONE) ;
        btn_add.set_tooltip_markup ("Commit") ;
        btn_add.clicked.connect (get_commit_message) ;

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

    private void setup_grid_int_stack() {
        main_window.t_stack.add_titled (grid, "staged", "Staged") ;
        main_window.t_stack.set_focus_child.connect ((e) => {
            load_page (_new_full_path) ;
        }) ;
    }

    public void update_list_model_tree_view() {
        _list_store.clear () ;

        Gtk.TreeIter iter ;
        for( int i = 0 ; i < _staged_files.size ; i++ ){
            _list_store.append (out iter) ;
            _list_store.set (iter, Column.ID, i, Column.FILE, _staged_files[i]) ;
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
        setup_grid_int_stack () ;

        update_list_model_tree_view () ;
    }
}
