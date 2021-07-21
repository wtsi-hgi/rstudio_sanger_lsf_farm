IMG_FORMAT = sif
TARGETS = $(shell ./generate-targets.sh $(IMG_FORMAT))

all: $(TARGETS)

%.$(IMG_FORMAT): %.def
	sudo singularity build "$@" "$^"

%.def:
	./generate-recipe.sh "$*" > "$@"

clean:
	rm -f *.$(IMG_FORMAT)

.PHONY: all clean
