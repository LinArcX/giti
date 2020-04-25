namespace GITI.Util{

    // send a system notification
    public void show_notification(string title, string body) {
        var notification = new GLib.Notification (title) ;
        notification.set_body (body) ;
        notification.set_icon (new ThemedIcon (GITI.Application.instance.application_id)) ;
        notification.set_priority (GLib.NotificationPriority.NORMAL) ;

        GITI.Application.instance.send_notification (GITI.Application.instance.application_id, notification) ;
    }

}
