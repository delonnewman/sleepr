.PHONY: install

install:
	dzil build
	cpanm --sudo Sleepr*.tar.gz
	sudo cp scripts/sleepr-init /etc/init.d/sleepr
	sudo ln -s /etc/init.d/sleepr /etc/rc2.d/S20sleepr
