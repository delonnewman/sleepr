#include "preferences-window.h"

gchar *UI_FILE = "/home/delon/Projects/Personal/sleepr-prefernces/share/sleepr/preferences-window.glade";

GtkWidget *
preferences_window_new ()
{
	GtkBuilder *builder = gtk_builder_new ();

	GError *error;

	gint res = gtk_builder_add_from_file (builder, UI_FILE, &error);
	if ( res == 0 ) {
		printf("%s Error: %s", g_quark_to_string(error->domain), error->message);
		gtk_main_quit();
	}

	GtkWidget *window = GTK_WINDOW (gtk_builder_get_object (builder, "PreferencesWindow"));

	return window;
}
