public class GITI.Application : Gtk.Application {
    public Application () {
        Object (application_id: "com.github.linarcx.giti",
                flags : ApplicationFlags.FLAGS_NONE) ;
    }

    public static GITI.Application _instance = null ;
    public static GITI.Application instance {
        get {
            if( _instance == null ){
                _instance = new GITI.Application () ;
            }
            return _instance ;
        }
    }

    protected override void activate() {
        var window = new GITI.Window (this) ;
        add_window (window) ;
    }

}
