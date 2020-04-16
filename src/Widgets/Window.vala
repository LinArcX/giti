namespace giti{
    public class Window : Gtk.ApplicationWindow {
// public File m_repo_path { get ; set ; }
// public Ggit.Repository m_repo { get ; set ; }
// public giti.GridStaged m_staged { get ; construct ; }
// public giti.GridUntracked m_untracked { get ; construct ; }

        public GLib.Settings settings ;
        public Gtk.Stack stack { get ; set ; }
        public Gtk.Application m_app { get ; construct ; }

        public Window (Application app) {
            Object (
                application: app,
                m_app: app) ;
        }

        construct {
            window_position = Gtk.WindowPosition.CENTER ;
            set_default_size (350, 80) ;

            settings = new GLib.Settings ("com.github.linarcx.giti") ;
            move (settings.get_int ("pos-x"), settings.get_int ("pos-y")) ;
            resize (settings.get_int ("window-width"), settings.get_int ("window-height")) ;

            delete_event.connect (e => {
                return before_destroy () ;
            }) ;

            stack = new Gtk.Stack () ;
            stack.expand = true ;

            // Ggit.init () ;

            // m_repo_path = File.new_for_path ("/mnt/D/workspace/other/lem") ;
            // try {
            // m_repo = Ggit.Repository.open (m_repo_path) ;
            //// print (m_repo_path.get_basename () + "\n") ;
            // } catch ( GLib.Error e ) {
            // critical ("Error git-repo open: %s", e.message) ;
            // }

            // m_untracked = new giti.GridUntracked (this, m_repo) ;
            // m_staged = new giti.GridStaged (this, m_repo) ;

            add (stack) ;

            var headerBar = new giti.HeaderBar (this) ;
            set_titlebar (headerBar) ;

            show_all () ;
        }

        public bool before_destroy() {
            int x, y, width, height ;
            get_size (out width, out height) ;
            get_position (out x, out y) ;
            settings.set_int ("pos-x", x) ;
            settings.set_int ("pos-y", y) ;
            settings.set_int ("window-width", width) ;
            settings.set_int ("window-height", height) ;
            return false ;
        }

    }
}
// public string[] m_dirs = {} ;
// public Gee.ArrayList<string> m_dirs = new Gee.ArrayList<string> () ;
