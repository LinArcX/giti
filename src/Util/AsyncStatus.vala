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

public class GITI.AsyncStatus : GLib.Object {

    int untracked_counter = 0 ;
    int staged_counter = 0 ;

    public GLib.Settings _settings ;
    public Ggit.Repository t_new_repo { get ; set ; }
    public GITI.Window main_window { get ; construct ; }

    public AsyncStatus (GITI.Window win) {
        Object (main_window: win) ;
    }

    private int check_status_for_each_file(string file_name, Ggit.StatusFlags status) {
        if( status == Ggit.StatusFlags.WORKING_TREE_NEW
            || status == Ggit.StatusFlags.WORKING_TREE_MODIFIED ){
            // || status == Ggit.StatusFlags.WORKING_TREE_DELETED ){
            untracked_counter++ ;
        }
        if( status == Ggit.StatusFlags.INDEX_NEW
            || status == Ggit.StatusFlags.INDEX_MODIFIED ){
            // || status == Ggit.StatusFlags.INDEX_DELETED ){
            staged_counter++ ;
        }
        return 0 ;
    }

    private void get_status(string _new_full_path) {
        File new_repo_path = File.new_for_path (_new_full_path) ;
        try {
            t_new_repo = Ggit.Repository.open (new_repo_path) ;
            t_new_repo.file_status_foreach (null, check_status_for_each_file) ;
        } catch ( GLib.Error e ) {
            critical ("Error git-repo open: %s", e.message) ;
        }
    }

    private bool task() {

        string[] _list_of_directories = _settings.get_strv ("directories") ;
        foreach( var i in _list_of_directories ){
            // print (i + "\n") ;
            get_status (i) ;
        }

        if( untracked_counter > 0 || staged_counter > 0 ){
            print ("Notification sent..\n") ;
            GITI.Util.show_notification (main_window.app, "Status",
                                         "Untracked files: " + untracked_counter.to_string () + ", " +
                                         "Staged files: " + staged_counter.to_string ()) ;
            untracked_counter = 0 ;
            staged_counter = 0 ;
        } else {
            print ("Your directories are clean.\n") ;
        }
        return true ; // false terminates timer
    }

    async void async_runner() {
        int period = _settings.get_int ("notification-period") ;
        if( period > 0 ){
            Timeout.add_seconds (period * 60, task) ;
        } else {
            print ("Seems you turned of notification feature!") ;
        }
    }

    public bool run_background_service() {
        _settings = new GLib.Settings ("com.github.linarcx.giti") ;

        async_runner.begin ((obj, res) => {
            async_runner.end (res) ;
        }) ;
        return true ;
    }

    construct {

    }
}
