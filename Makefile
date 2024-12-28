#
# Makefie for Duplicacy Scripts
#

# Configure the following to taste.

# Suitable for general use:

# Root of backup
ROOT=/

# Where the scripts and data should be installed
DEST=/opt/duplicacy

# Suitable for experimentation in /tmp
#ROOT=/tmp
#DEST=/tmp/duplicacy-scripts

# Where to link the binary for command-line use
BINARY_LINK=/usr/local/bin

# No user-serviceable parts below this point.

GIT_URL=https://github.com/markfeit/duplicacy-scripts.git
GIT_BRANCH=origin/master

BIN=$(DEST)/bin
ETC=$(DEST)/etc
LIB=$(DEST)/lib
PREFS=$(DEST)/prefs
VAR=$(DEST)/var

CACHE=$(VAR)/cache
HOLE=$(VAR)/hole
LOG=$(VAR)/log
UPDATE=$(VAR)/update

DUPLICACY_BINARY=$(BIN)/duplicacy
DIST_CLEAN += $(DUPLICACY_BINARY)

default:
	@echo Nothing to do.


$(DEST):
	mkdir -p $@


ROOT_LINK=$(DEST)/root
$(ROOT_LINK): $(DEST)
	rm -f $@
	ln -s "$(shell cd $(ROOT) && pwd -P)" $@

$(DEST)/%:
	mkdir -p $@

# File that points Duplicacy at its local storage
LOCATION_FILE=$(ROOT)/.duplicacy
$(LOCATION_FILE): $(ROOT)
	rm -f $@
	echo "$(shell cd $(DEST)/prefs && pwd)" > $@


# Duplicacy binary.

$(DUPLICACY_BINARY): FORCE
	./bin/download-duplicacy "$@"

# Crontab
CRONTAB=$(LIB)/crontab
$(CRONTAB)::
	mkdir -p $(LIB)
	sed -e 's|__BIN__|$(BIN)|g' lib/crontab > $@


# Prime updating with a full copy of the sources unless we're already
# doing an update from that directory.

$(UPDATE)::
ifeq ($(NO_GIT),)
	rm -rf $@
	mkdir -p $@
	cp -r $(shell ls -a | egrep -v -e '^(\.+|test)$$') $@
	(cd "$@" && git remote set-url origin "$(GIT_URL)")
else
	@true
endif

# If files in etc differ from what was installed, install them as
# *-upgrade and let the user sort it out.

install: clean \
	$(BIN) $(DUPLICACY_BINARY) \
	$(ETC) \
	$(LIB) \
	$(CRONTAB) \
	$(PREFS) \
	$(LOCATION_FILE) \
	$(LINKED_BINARY) \
	$(CACHE) $(HOLE) $(LOG) $(UPDATE) \
	$(ROOT_LINK)
	cp -rfp bin/* $(BIN)
	for FILE in etc/* ; \
	do \
	    BASE=$$(basename "$${FILE}") ; \
	    if [ ! -e "$(ETC)/$${BASE}" ] ; \
	    then \
	        cp -fp "$${FILE}" "$(ETC)" ; \
	    else \
	        [ -e "$(ETC)/$${BASE}" ] \
	            && diff "$${FILE}" "$(ETC)/$${BASE}" > /dev/null \
	            && continue ; \
	        [ -e "$(ETC)/$$BASE" ] \
	            && cp -fp "$${FILE}" "$(ETC)/$${BASE}-upgrade" \
	            || cp -fp "$${FILE}" "$(ETC)" ; \
	    fi ; \
	done
	rm -rf "$(PREFS)/logs"
	ln -s "../var/hole" "$(PREFS)/logs"
	rm -rf "$(PREFS)/cache"
	ln -s "../var/cache" "$(PREFS)/cache"
ifeq ($(TEST_BUILD),)
	crontab -l | $(BIN)/crontab-install | crontab -
endif

# $(LINKED_BINARY) is a special case that gets handled in the
# uninstall target.
TO_UNINSTALL += $(BIN) $(LIB) $(LOCATION_FILE)


update:
	git fetch
	if [ $$(git diff $(GIT_BRANCH) | wc -l) -gt 0 ]; \
	then \
	    git merge $(GIT_BRANCH) \
	    && $(MAKE) NO_GIT=1 install ; \
	fi


uninstall:
ifeq ($(TEST_BUILD),)
	crontab -l | $(BIN)/crontab-remove | crontab -
endif
	rm -rf $(TO_UNINSTALL)
	if [ -w "$(BINARY_LINK)" ]; then rm -f "$(LINKED_BINARY)" ; fi
	@echo "NOTE:  Configuration, cache and logs were left in place."


# Install a test copy
TEST_DIR=test
TEST_DEST=$(TEST_DIR)/duplicacy
TEST_ROOT=$(TEST_DIR)/root

$(TEST_ROOT) $(TEST_DEST):
	rm -rf $@
	mkdir -p $@

test: $(TEST_ROOT) $(TEST_DEST)
	$(MAKE) \
	    DEST=$(TEST_DEST) \
	    ROOT=$(TEST_ROOT) \
	    TEST_BUILD=1 \
	    install
TO_CLEAN += $(TEST_DIR) $(TEST_ROOT)


clean:
	rm -rf $(TO_CLEAN)
	find . -name "*~" | xargs rm -f

distclean: clean
	rm -rf $(DIST_CLEAN)


FORCE:
