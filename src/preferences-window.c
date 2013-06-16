#include "preferences_window.h"

GtkWindow *
preferences_window_new ()
{
	GtkBuilder *builder = gtk_builder_new ();

	gint res = gtk_builder_add_from_file (builder, UI_FILE);
	if ( res == 0 ) {
		printf("%s Error: %s", g_quark_to_string(GError->domain), GError->message);
		exit(1);
	}

	GtkWindow *window = gtk_builder_get_object (builder, "PreferencesWindow");

	return window;
}
