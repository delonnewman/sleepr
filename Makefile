.PHONY: install all

CC=gcc
FLAGS=`pkg-config --cflags gtk+-3.0`
LIBS=`pkg-config --libs gtk+-3.0`

all: bin/sleepr-preferences

clean:
	rm -f bin/sleepr-preferences
	rm -f src/*.o


src/preferences-window.o:
	$(CC) $(FLAGS) -c -o src/preferences-window.o src/preferences-window.c $(LIBS)

src/main.o:
	$(CC) $(FLAGS) -c -o src/main.o src/main.c $(LIBS)

bin/sleepr-preferences: src/main.o src/preferences-window.o
	$(CC) $(FLAGS) -o bin/sleepr-preferences src/main.o src/preferences-window.o $(LIBS)

install:
	dzil build
	cpanm --sudo Sleepr*.tar.gz
	sudo cp scripts/sleepr-init /etc/init.d/sleepr
	sudo ln -s /etc/init.d/sleepr /etc/rc2.d/S20sleepr
