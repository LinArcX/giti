public class GITI.WelcomeHeaderBar : Gtk.HeaderBar {

    construct {
        set_show_close_button (true) ;
        var default_settings = Gtk.Settings.get_default () ;

        var _granite_mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic") ;
        _granite_mode_switch.valign = Gtk.Align.CENTER ;
        _granite_mode_switch.primary_icon_tooltip_text = "Light background" ;
        _granite_mode_switch.secondary_icon_tooltip_text = "Dark background" ;
        _granite_mode_switch.bind_property ("active", default_settings, "gtk_application_prefer_dark_theme") ;

        pack_end (_granite_mode_switch) ;
    }
}
