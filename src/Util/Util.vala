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
