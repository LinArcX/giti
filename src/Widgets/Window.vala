namespace GITI{
    public class Window : Gtk.ApplicationWindow {

        public GLib.Settings _settings ;
        public Gtk.Stack _stack { get ; set ; }
        public Gtk.Application app { get ; set ; }

        public GITI.HeaderBar _main_header_bar { get ; set ; }

        public GITI.WelcomePage _welcome_page { get ; set ; }
        public GITI.WelcomeHeaderBar _welcome_header_bar { get ; set ; }

        public Window (Application app) {
            Object (
                application: app,
                app: app) ;
        }

        private void set_settings() {
            set_default_size (750, 430) ;
            window_position = Gtk.WindowPosition.CENTER ;

            _settings = new GLib.Settings ("com.github.linarcx.giti") ;
            move (_settings.get_int ("pos-x"), _settings.get_int ("pos-y")) ;
            resize (_settings.get_int ("window-width"), _settings.get_int ("window-height")) ;
        }

        public bool before_destroy() {
            int x, y, width, height ;
            get_size (out width, out height) ;
            get_position (out x, out y) ;
            _settings.set_int ("pos-x", x) ;
            _settings.set_int ("pos-y", y) ;
            _settings.set_int ("window-width", width) ;
            _settings.set_int ("window-height", height) ;
            return false ;
        }

        private void setup_screens() {
            string[] _list_of_directories = _settings.get_strv ("directories") ;

            if( _list_of_directories.length == 0 ){
                _welcome_page = new GITI.WelcomePage (this) ;
                _welcome_header_bar = new GITI.WelcomeHeaderBar () ;
                set_titlebar (_welcome_header_bar) ;
                add (_welcome_page) ;
            } else {
                _main_header_bar = new GITI.HeaderBar (this) ;
                set_titlebar (_main_header_bar) ;
                add (_stack) ;
            }
        }

        construct {
            set_settings () ;

            delete_event.connect (e => {
                return before_destroy () ;
            }) ;

            _stack = new Gtk.Stack () ;
            _stack.expand = true ;

            setup_screens () ;
            show_all () ;
        }
    }
}
