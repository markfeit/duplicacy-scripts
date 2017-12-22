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

GIT_URL=https://github.com/markfeit/duplicacy-scripts.git

BIN=$(DEST)/bin
ETC=$(DEST)/etc
LIB=$(DEST)/lib
PREFS=$(DEST)/prefs
VAR=$(DEST)/var

HOLE=$(VAR)/hole
UPDATE=$(VAR)/update


default:
	@echo Nothing to do.


$(DEST):
	mkdir -p $@

$(DEST)/root:
	rm -f $@
	ln -s "$(ROOT)" $@

$(DEST)/%:
	mkdir -p $@

# File that points Duplicacy at its local storage
LOCATION_FILE=$(ROOT)/.duplicacy
$(LOCATION_FILE): $(ROOT)
	rm -f $@
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
	if [ -w "$(BINARY_LINK)" ]; then rm -f $@ ; fi
	if [ -w "$(BINARY_LINK)" ]; then ln -s $< $@ ; fi


# Crontab
CRONTAB=$(LIB)/crontab
$(CRONTAB): lib/crontab $(LIB) 
	sed -e 's|__BIN__|$(BIN)|g' $< > $@


# Prime updating with a full copy of the sources unless we're already
# doing an update from that directory.

$(UPDATE)::
ifeq ($(NO_GIT),)
	rm -rf $@
	mkdir -p $@
	cp -r * .??* $@
	(cd "$@" && git remote set-url origin "$(GIT_URL)")
else
	@echo "Already in sources pulled from GitHub"
endif

# If files in etc differ from what was installed, install them as
# *-upgrade and let the user sort it out.

install: clean $(BIN) $(BIN)/duplicacy $(ETC) $(LIB) $(CRONTAB) \
	$(PREFS) $(LOCATION_FILE) $(LINKED_BINARY) $(UPDATE)
	cp -r bin/* $(BIN)
	for FILE in etc/* ; \
	do \
	    BASE=$$(basename "$${FILE}") ; \
	    if [ ! -e "$(ETC)/$${BASE}" ] ; \
	    then \
	        cp -f "$${FILE}" "$(ETC)" ; \
	    else \
	        [ -e "$(ETC)/$${BASE}" ] \
	            && diff "$${FILE}" "$(ETC)/$${BASE}" > /dev/null \
	            && continue ; \
	        [ -e "$(ETC)/$$BASE" ] \
	            && cp -f "$${FILE}" "$(ETC)/$${BASE}-upgrade" \
	            || cp -f "$${FILE}" "$(ETC)" ; \
	    fi ; \
	done
	mkdir -p "$(HOLE)"
	rm -rf "$(DEST)/prefs/logs"
	ln -s "../var/hole" "$(DEST)/prefs/logs"
	crontab -l | $(BIN)/crontab-install | crontab -

# $(LINKED_BINARY) is a special case that gets handled in the
# uninstall target.
TO_UNINSTALL += $(BIN) $(LIB) $(LOCATION_FILE)


update:
	git pull
	$(MAKE) NO_GIT=1 install

uninstall:
	crontab -l | $(BIN)/crontab-remove | crontab -
	rm -rf $(TO_UNINSTALL)
	if [ -w "$(BINARY_LINK)" ]; then rm -f "$(LINKED_BINARY)" ; fi
	@echo "NOTE:  Configuration, cache and logs were left in place."


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -f

distclean: clean
	rm -rf $(DIST_CLEAN)
