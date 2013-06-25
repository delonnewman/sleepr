#include "preferences-window.h"

int
main (int argc, char *argv[])
{
	GtkWidget *window;

	gtk_init (&argc, &argv);

	window = preferences_window_new ();

	gtk_widget_show (window);

	gtk_main ();

	return 0;
}
