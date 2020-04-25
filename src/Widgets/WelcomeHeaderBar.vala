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
