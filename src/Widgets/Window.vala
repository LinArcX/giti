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

namespace GITI{
    public class Window : Gtk.ApplicationWindow {

        public GLib.Settings _settings ;
        public Gtk.Stack t_stack { get ; set ; }
        public Gtk.Application app { get ; set ; }

        public GITI.HeaderBar t_main_header_bar { get ; set ; }
        public GITI.WelcomePage t_welcome_page { get ; set ; }
        public GITI.WelcomeHeaderBar t_welcome_header_bar { get ; set ; }

        public Window (Application app) {
            Object (
                application: app,
                app: app) ;
        }

        public const string ACTION_GROUP_PREFIX = "win" ;
        public const string ACTION_PREFIX = ACTION_GROUP_PREFIX + "." ;
        public const string ACTION_PREFERENCES = "preferences" ;
        public const string ACTION_ABOUT = "about" ;
        public const string ACTION_QUIT = "quit" ;

        private static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> () ;

        private const ActionEntry[] ACTION_ENTRIES = {
            { ACTION_PREFERENCES, on_preferences },
            { ACTION_ABOUT, on_about },
            { ACTION_QUIT, on_quit },
        } ;

        static construct {
            action_accelerators[ACTION_PREFERENCES] = "<Control>p" ;
            action_accelerators[ACTION_ABOUT] = "F1" ;
            action_accelerators[ACTION_QUIT] = "<Control>q" ;
        }

        private void on_preferences() {
            var preferences_dialog = new Gtk.Dialog.with_buttons (
                "Title",
                this,
                Gtk.DialogFlags.MODAL |
                Gtk.DialogFlags.DESTROY_WITH_PARENT |
                Gtk.DialogFlags.USE_HEADER_BAR
                ) ;
            preferences_dialog.resizable = false ;
            preferences_dialog.default_width = 300 ;
            preferences_dialog.default_height = 170 ;
            preferences_dialog.border_width = 5 ;
            // preferences_dialog.deletable = false ;
            // preferences_dialog.decorated = true ;

            var content_area = preferences_dialog.get_content_area () ;

            // Font
            var lbl_font = new Gtk.Label ("Font:") ;
            lbl_font.set_justify (Gtk.Justification.LEFT) ;
            lbl_font.halign = Gtk.Align.START ;
            lbl_font.valign = Gtk.Align.START ;

            var btn_font = new Gtk.FontButton () ;

            var sep_hz = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) ;
            sep_hz.margin = 10 ;

            // Notification period
            var lbl_commit = new Gtk.Label ("Send notification every(minute):") ;
            lbl_commit.set_justify (Gtk.Justification.LEFT) ;
            lbl_commit.halign = Gtk.Align.START ;
            lbl_commit.valign = Gtk.Align.START ;

            var spb_notification_period = new Gtk.SpinButton.with_range (0, 180, 1) ;
            spb_notification_period.value = (double) (_settings.get_int ("notification-period")) ;

            var sep_hz_2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) ;
            sep_hz_2.margin = 10 ;

            // Reset settings
            var btn_reset_settings = new Gtk.Button.with_label ("Reset to default settings") ;
            btn_reset_settings.get_style_context ().add_class ("destructive-action") ; // blue: "suggested-action"
            btn_reset_settings.clicked.connect (() => {
                _settings.reset ("notification-period") ;
                spb_notification_period.value = (double) (_settings.get_int ("notification-period")) ;
            }) ;

            content_area.add (lbl_font) ;
            content_area.add (btn_font) ;
            content_area.add (sep_hz) ;

            content_area.add (lbl_commit) ;
            content_area.add (spb_notification_period) ;
            content_area.add (sep_hz_2) ;

            content_area.add (btn_reset_settings) ;

            preferences_dialog.close.connect (() => {
                _settings.set_int ("notification-period", (int) (spb_notification_period.value)) ;
            }) ;

            preferences_dialog.destroy.connect (() => {
                _settings.set_int ("notification-period", (int) (spb_notification_period.value)) ;
            }) ;

            preferences_dialog.show_all () ;
            preferences_dialog.present () ;
        }

        private void on_about() {
            Gtk.AboutDialog dialog = new Gtk.AboutDialog () ;
            dialog.set_destroy_with_parent (true) ;
            dialog.set_transient_for (this) ;
            dialog.set_modal (true) ;
            dialog.logo_icon_name = "com.github.linarcx.giti" ;

            dialog.authors = { "LinArcX", "LinArcX" } ;
            dialog.documenters = null ;
            dialog.translator_credits = null ;

            dialog.program_name = "giti" ;
            dialog.comments = "Permanent observer of your git directories" ;
            dialog.copyright = "Copyright (C) 2007 Free Software Foundation, Inc" ;
            dialog.version = "1.0.0" ;

            dialog.license_type = Gtk.License.GPL_3_0_ONLY ;
            dialog.wrap_license = true ;

            dialog.website = "https://github.com/LinArcX/giti" ;
            dialog.website_label = "https://github.com/LinArcX/giti" ;

            dialog.response.connect ((response_id) => {
                if( response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT ){
                    dialog.hide_on_delete () ;
                }
            }) ;

            // Show the dialog:
            dialog.present () ;

        }

        private void on_quit() {
            print ("Bye dude! Take care...") ;
            before_destroy () ;
            close () ;
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
                t_welcome_page = new GITI.WelcomePage (this) ;
                t_welcome_header_bar = new GITI.WelcomeHeaderBar () ;
                set_titlebar (t_welcome_header_bar) ;
                add (t_welcome_page) ;
            } else {
                t_main_header_bar = new GITI.HeaderBar (this) ;
                set_titlebar (t_main_header_bar) ;
                add (t_stack) ;

                // run background status checking..
                var async_status = new GITI.AsyncStatus (this) ;
                async_status.run_background_service () ;
            }
        }

        construct {
            add_action_entries (ACTION_ENTRIES, this) ;

            foreach( var action in action_accelerators.get_keys ()){
                ((Gtk.Application)GLib.Application.get_default ()).set_accels_for_action (
                    ACTION_PREFIX + action,
                    action_accelerators[action].to_array ()
                    ) ;
            }

            set_settings () ;

            delete_event.connect (e => {
                return before_destroy () ;
            }) ;

            t_stack = new Gtk.Stack () ;
            t_stack.expand = true ;

            setup_screens () ;
            show_all () ;
        }
    }
}
