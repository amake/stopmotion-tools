SHELL := /bin/bash

# Requires ffmpeg

jpg_glob := *.JPG
jpg := $(wildcard $(jpg_glob))
ffmpeg_flags :=

.PHONY:
all: silent-pingpong.mp4 $(if $(wildcard *.m4a),with-audio-pingpong.mp4)

silent.mp4: $(jpg)
# ffmpeg video filter -vf
# - resizes to iPhone XS max video resolution
	ffmpeg -y $(ffmpeg_flags) -framerate 10 -pattern_type glob -i '$(jpg_glob)' -vf 'scale=1920:-1' -pix_fmt yuv420p $@

with-audio.mp4: silent.mp4 audio.m4a
	ffmpeg -y $(ffmpeg_flags) -i $< -i $(word 2,$^) -c copy -map 0:v:0 -map 1:a:0 -shortest $@

%-pingpong.mp4: %.mp4 %-reversed.mp4
	ffmpeg -y $(ffmpeg_flags) -f concat -safe 0 -i <(printf "file '%s'\n" $(addprefix $(PWD)/,$^)) -c copy $@

%.jpg: %.HEIC
	heif-convert $< $@

%-reversed.mp4: %.mp4
	ffmpeg -y $(ffmpeg_flags) -i $< -vf reverse -af areverse $@


.PHONY: clean
clean:
	rm *.mp4

.PHONY: preview
preview: silent.mp4
	ffplay -loop 2 -noborder -alwaysontop -autoexit $(<)

watchdir=

.PHONY: watch
watch:
	$(if $(watchdir),,$(error Specify watchdir=))
	./monitor $(watchdir) $(PWD)
