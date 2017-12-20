#
# Makefie for Duplicacy Scripts
#

# Configure the following to taste.

# Suitable for general use:

# Root of backup
ROOT=/

# Where the scripts and data should be installed
DEST=/system/duplicacy

# Suitable for experimentation in /tmp
#ROOT=/tmp
#DEST=/tmp/duplicacy-scripts

DUPLICACY_BINARY=duplicacy_linux_x64_2.0.10
DIST_CLEAN += $(DUPLICACY_BINARY)

# Where to link the binary for command-line use
BINARY_LINK=/usr/local/bin

# No user-serviceable parts below this point.

BIN=$(DEST)/bin
ETC=$(DEST)/etc
LIB=$(DEST)/lib
PREFS=$(DEST)/prefs


default:
	@echo Nothing to do.


$(DEST):
	mkdir -p $@

$(DEST)/%:
	mkdir -p $@

# File that points Duplicacy at its local storage
LOCATION_FILE=$(ROOT)/.duplicacy
$(LOCATION_FILE): $(ROOT)
	echo "$(DEST)/prefs" > $@


# Duplicacy binary.
$(BIN)/$(DUPLICACY_BINARY): $(DUPLICACY_BINARY) $(BIN)
	rm -f $@
	cp $< $@
	chmod 555 $@

$(BIN)/duplicacy: $(BIN)/$(DUPLICACY_BINARY) $(BIN)
	rm -f $@
	ln -s $(DUPLICACY_BINARY) $@

LINKED_BINARY=$(BINARY_LINK)/duplicacy
$(LINKED_BINARY): $(BIN)/$(DUPLICACY_BINARY)
	rm -f $@
	ln -s $< $@


# Crontab
CRONTAB=$(LIB)/crontab
$(CRONTAB): lib/crontab $(LIB) 
	sed -e 's|__BIN__|$(BIN)|g' $< > $@

install: $(BIN) $(BIN)/duplicacy $(ETC) $(LIB) $(CRONTAB) \
	$(PREFS) $(LOCATION_FILE) $(LINKED_BINARY)
	cp -r bin/* $(BIN)
	cp -r etc/* $(ETC)
	rm -f $(DEST)/root
	ln -s "$(ROOT)" $(DEST)/root
	crontab -l | $(BIN)/crontab-install | crontab -
TO_UNINSTALL += $(BIN) $(LIB) $(LOCATION_FILE) $(LINKED_BINARY)

update:
	git pull
	$(MAKE) install

uninstall:
	crontab -l | $(BIN)/crontab-remove | crontab -
	rm -rf $(TO_UNINSTALL)
	@echo "NOTE:  Configuration, cache and logs were left in place."


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -f

distclean: clean
	rm -rf $(DIST_CLEAN)
