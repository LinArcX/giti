public class Application : Gtk.Application {
    public Application () {
        Object (application_id: "com.github.linarcx.giti",
                flags : ApplicationFlags.FLAGS_NONE) ;
    }

    protected override void activate() {
        var window = new GITI.Window (this) ;
        add_window (window) ;
    }

}
