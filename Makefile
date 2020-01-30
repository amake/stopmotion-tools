SHELL := /bin/bash

# Requires ffmpeg

jpg_glob := *.JPG
jpg := $(wildcard $(jpg_glob))

.PHONY:
all: silent-pingpong.mp4 with-audio-pingpong.mp4

silent.mp4: $(jpg)
# ffmpeg video filter -vf
# - resizes to iPhone XS max video resolution
	ffmpeg -framerate 10 -pattern_type glob -i '$(jpg_glob)' -vf 'scale=1920:-1' $@

with-audio.mp4: silent.mp4 audio.m4a
	ffmpeg -i $< -i $(word 2,$^) -c copy -map 0:v:0 -map 1:a:0 -shortest $@

%-pingpong.mp4: %.mp4 %-reversed.mp4
	ffmpeg -f concat -safe 0 -i <(printf "file '%s'\n" $(addprefix $(PWD)/,$^)) -c copy $@

%.jpg: %.HEIC
	heif-convert $< $@

%-reversed.mp4: %.mp4
	ffmpeg -i $< -vf reverse -af areverse $@


.PHONY: clean
clean:
	rm *.mp4
