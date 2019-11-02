SUB_DIRS = $(wildcard ice*/.) loader unknown

build:
	for dir in $(SUB_DIRS); do \
	    $(MAKE) -C $$dir build; \
	done;
	./gen_mcs.sh

clean:
	for dir in $(SUB_DIRS); do \
	    $(MAKE) -C $$dir clean; \
	done;
	rm -rf icemulti

clobber:
	for dir in $(SUB_DIRS); do \
	    $(MAKE) -C $$dir clobber; \
	done;
