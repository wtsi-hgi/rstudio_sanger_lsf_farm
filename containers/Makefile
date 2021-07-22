# Copyright (c) 2021 Genome Research Ltd.
#
# Author: Christopher Harrison <ch12@sanger.ac.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

BUILD   = build
FORMAT  = sif
TARGETS = $(shell ./generate-targets.sh)

all: $(TARGETS:%=$(BUILD)/%.$(FORMAT))

$(BUILD)/%.$(FORMAT): $(BUILD)/%.def | $(BUILD)
	sudo singularity build "$@" "$^"

$(BUILD)/%.def: | $(BUILD)
	./generate-recipe.sh "$*" > "$@"

$(BUILD):
	mkdir $@

clean:
	rm -rf $(BUILD)

.PHONY: all clean
