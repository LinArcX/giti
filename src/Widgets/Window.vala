namespace giti{
    public class Window : Gtk.ApplicationWindow {

        public GLib.Settings settings ;
        public Gtk.Stack stack { get ; set ; }
        public Gtk.Application m_app { get ; construct ; }

        public giti.HeaderBar main_header_bar { get ; set ; }
        public giti.WelcomeView welcome_view { get ; set ; }
        public giti.WelcomeHeaderBar welcome_header_bar { get ; set ; }

        public Window (Application app) {
            Object (
                application: app,
                m_app: app) ;
        }

        construct {
            set_settings () ;

            delete_event.connect (e => {
                return before_destroy () ;
            }) ;

            stack = new Gtk.Stack () ;
            stack.expand = true ;

            setup_screens () ;
            show_all () ;
        }

        private void set_settings() {
            set_default_size (350, 80) ;
            window_position = Gtk.WindowPosition.CENTER ;

            settings = new GLib.Settings ("com.github.linarcx.giti") ;
            move (settings.get_int ("pos-x"), settings.get_int ("pos-y")) ;
            resize (settings.get_int ("window-width"), settings.get_int ("window-height")) ;
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

        private void setup_screens() {
            string[] m_dirs = settings.get_strv ("directories") ;
            if( m_dirs.length == 0 ){
                welcome_view = new giti.WelcomeView (this) ;
                welcome_header_bar = new giti.WelcomeHeaderBar () ;
                set_titlebar (welcome_header_bar) ;
                add (welcome_view) ;
            } else {
                main_header_bar = new giti.HeaderBar (this) ;
                add (stack) ;
                set_titlebar (main_header_bar) ;
            }
        }

    }
}
