RECIPIES = $(wildcard *.def)
IMAGES = $(RECIPIES:%.def=%.sif)

all: $(IMAGES)

clean:
	rm -f $(IMAGES)

.PHONY: all clean

.SECONDEXPANSION:

%.sif: $$*.def
	sudo singularity build "$@" "$^"
