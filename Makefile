################################################################################
# Makefile                                                                     #
#                                                                              #
# Makefile for user space initialization and capture programs for              #
# Somagic EasyCAP DC60 and Somagic EasyCAP 002                                 #
# ##############################################################################
#
# Copyright 2011, 2012 Jeffry Johnston
#
# This file is part of somagic_easycap
# http://code.google.com/p/easycap-somagic-linux/
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

SHELL = /bin/sh
PREFIX = /usr
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/share/man
PROGRAMS = somagic-init somagic-capture somagic-audio-capture somagic-both
MANUALS = man/somagic-init.1 man/somagic-capture.1
CFLAGS = -s -W -Wall
LFLAGS = -lusb-1.0 -lgcrypt

.SUFFIXES:
.SUFFIXES: .c

.PHONY: all
all: $(PROGRAMS)

.c:
	$(CC) $(CFLAGS) $< -o $@ $(LFLAGS)

install: $(PROGRAMS)
	install -D -m755 $(PROGRAMS) $(BINDIR)
	@printf "$(PROGRAMS) installed to $(BINDIR)!\n\n"
	install -Dm644 somagic_firmware.bin /usr/lib/firmware/somagic_firmware.bin
	@printf "Copied firmware blob to /usr/lib/firmware/somagic_firmware.bin\n\n"
	install -m644 50-somagic.rules /usr/lib/udev/rules.d
	@printf "$(PROGRAMS) udev rules installed to /usr/lib/udev/rules.d/50-somagic.rules!\n\n"
	@printf "Trying to add group somagic...\n"
	-groupadd somagic > /dev/null
	@printf "\nTrying to add current user to group somagic...\n"
	usermod -a -G somagic $(SUDO_USER)
	@printf "\nReloading udev...\n"
	udevadm control --reload
	udevadm trigger
	@printf "\nCopying license files...\n"
	install -Dm644 LICENSE /usr/share/licenses/easycap-somagic/LICENSE
	install -Dm644 LICENSE.firmware /usr/share/licenses/easycap-somagic/LICENSE.firmware

uninstall: $(BINDIR)/$(PROGRAMS)
	cd $(BINDIR) && rm -rf $(PROGRAMS)
	@printf "$(PROGRAMS) removed from $(BINDIR)!\n\n"
	-rm -rf /usr/lib/firmware/somagic_firmware.bin
	@printf "Removed firmware blob from /usr/lib/firmware/somagic_firmware.bin!\n\n"
	-rm -rf /usr/lib/udev/rules.d/50-somagic.rules
	@printf "Removed /usr/lib/udev/rules.d/50-somagic.rules udev rules!\n\n"
	@printf "Reloading udev...\n"
	udevadm control --reload
	udevadm trigger
	@printf "\nTrying to remove group somagic...\n"
	-groupdel somagic > /dev/null
	@printf "\nRemoving license files...\n"
	-rm -rf /usr/share/licenses/easycap-somagic

.PHONY: clean
clean:
	-rm -rf $(PROGRAMS)
