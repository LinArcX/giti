namespace GITI.Util{

    // send a system notification
    public void show_notification(Gtk.Application app, string title, string body) {
        var notification = new GLib.Notification (title) ;
        notification.set_body (body) ;
        notification.set_icon (new ThemedIcon (app.application_id)) ;
        notification.set_priority (GLib.NotificationPriority.NORMAL) ;
        app.send_notification (app.application_id, notification) ;
    }

}
