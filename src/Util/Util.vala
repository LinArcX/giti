namespace GITI.Util{

    // send a system notification
    public void show_notification(Gtk.Application app, string app_code, string title, string body, string icon_name) {
        var notification = new GLib.Notification (title) ;
        var icon = new GLib.ThemedIcon (icon_name) ;
        notification.set_body (body) ;
        notification.set_icon (icon) ;
        app.send_notification (app_code, notification) ;
    }

}
