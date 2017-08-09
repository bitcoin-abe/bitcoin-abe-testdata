# This Makefile should be built only after altering the *.in files
# generated files hould be comitted for the test suite
#
# As of this writing, json was printed using bitcoin-core v14.2
#
# Copyright(C) 2017 by Abe developers.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/agpl.html>.


Bitcoin_%.json: Bitcoin_%.in
	echo GEN $@
	bitcoin-cli -? >/dev/null 2>&1 || \
		{ echo "bitcoin-cli not found in PATH; cannot generate Bitcoin data" >&2; false; }
	bash -c 'echo -n "["; c=""; \
		case $< in \
			*_tx.in) \
				cmd=decoderawtransaction \
				;; \
			*_script.in) \
				cmd=decodescript \
				;; \
			*) \
				{ echo "No decode command for $<" >&2; exit 1; } \
		esac; \
		for tx in $$(sed -r "/^[#$$]/d" $<); do \
		echo "$$c"; echo -n "[\"$$tx\", "; echo $$tx|bitcoin-cli -stdin decoderawtransaction; echo -n "]"; c=","; done; \
		echo -e "\n]"' _ $< >$@ || { rm -f $@; false; }

all: $(patsubst %.in, %.json, $(wildcard *.in))

clean:
	@echo CLEAN *.json
	rm -f *.json

.SILENT:

