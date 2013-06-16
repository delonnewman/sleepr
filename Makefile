.PHONY: install all

CC=gcc
FLAGS=`pkg-config --cflags gtk+-3.0`
LIBS=`pkg-config --libs gtk+-3.0`

all: bin/sleepr-preferences

clean:
	rm bin/sleepr-preferences
	rm src/*.o


src/preferences_window.o:
	$(CC) $(FLAGS) -o src/preferences_window.o src/preferences_window.c $(LIBS)

bin/sleepr-preferences: src/preferences_window.o
	$(CC) $(FLAGS) -o bin/sleepr-preferences src/main.c $(LIBS)

install:
	dzil build
	cpanm --sudo Sleepr*.tar.gz
	sudo cp scripts/sleepr-init /etc/init.d/sleepr
	sudo ln -s /etc/init.d/sleepr /etc/rc2.d/S20sleepr
