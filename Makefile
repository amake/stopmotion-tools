SHELL := /bin/bash

# Requires ffmpeg

jpg_glob := *.JPG
jpg := $(wildcard $(jpg_glob))
ffmpeg_flags :=
video_width := 1920

.PHONY:
all: silent-pingpong.mp4 $(if $(wildcard *.m4a),with-audio-pingpong.mp4)

preview.mp4: video_width := 720
preview.mp4: ffmpeg_flags += -preset ultrafast
preview.mp4 silent.mp4: $(jpg)
# ffmpeg video filter -vf
# - resizes to iPhone XS max video resolution
	$(if $(<),ffmpeg -y \
		-framerate 10 \
		-pattern_type glob -i '$(jpg_glob)' \
		$(ffmpeg_flags) \
		-vf 'scale=$(video_width):-1' \
		-pix_fmt yuv420p \
		$@,$(warning No source images found; skipping creating $@))

with-audio.mp4: silent.mp4 audio.m4a
	ffmpeg -y -i $< -i $(word 2,$^) $(ffmpeg_flags) -c copy -map 0:v:0 -map 1:a:0 -shortest $@

%-pingpong.mp4: %.mp4 %-reversed.mp4
	ffmpeg -y -f concat -safe 0 -i <(printf "file '%s'\n" $(addprefix $(PWD)/,$^)) -c copy $(ffmpeg_flags) $@

%.jpg: %.HEIC
	heif-convert $< $@

%-reversed.mp4: %.mp4
	ffmpeg -y -i $< $(ffmpeg_flags) -vf reverse -af areverse $@


.PHONY: clean
clean:
	rm *.mp4

.PHONY: preview
preview: preview.mp4
	ffplay -loop 2 -noborder -alwaysontop -autoexit $(<)

watchdir=

.PHONY: watch
watch:
	$(if $(watchdir),,$(error Specify watchdir=))
	./monitor $(watchdir) $(PWD)
