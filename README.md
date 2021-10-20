# Some [more or less custom] Nemo actions

**Update** since some versions of nemo, some actions doesn't works anymore. This is due to [an issue](https://github.com/linuxmint/nemo/issues/2274) in nemo actions files parsing. Until this problem is solved, those actions won't work anymore (this is a problem parsing `%` of bash parameter expansion)

## Audio / Video

![](screenshots/sound_conversion.png) ![](screenshots/flac_to_wav.png) ![](screenshots/image_resize.png) ![](screenshots/stabilize_videos.png)

  * **extract_sound** : use **ffmpeg** to extract sound from video, and create a sound file in the same dir (with corresponding extension)
  * **concatenate_wavs** : use **sox** to concatenate multiple wavs, and create a resulting wav file in the same dir (named as concatenation of wavs filenames)
  * **convert_to_mp3** : use **lame** to convert files to mp3, and create sound files in the same dir (with corresponding extension). No check is done on the file format (must be wav)
  * **convert_to_wav** : use **ffmpeg** to convert files to wav, and create sound files in the same dir (with corresponding extension).
  * **convert_to_flac** : use **flac** to convert files to flac, and create sound files in the same dir (with corresponding extension). No check is done on the file format (must be wav)
  * **normalize audio** : use **ffmpeg** to normalize audio levels (using `loudnorm` filter), and create sound files in the same dir (with "-norm" appended to name). No check is done on the file format (must be wav)
  * **flac_to_wav** : use **flac** to extract selected flac file(s) to wav
  * **image_resize** : use **mogrify** to resize images
  * **stabilize_videos** : use **ffmpeg / libvid.stab** to stabilize a video file, or all videos inside a directory, and display advancement using **zenity**
  * **remove_empty_dirs** : recursively remove dirs that do not contains any file
  * **remove_node_modules** : recursively remove `node_modules` dirs

## Others

  * **paste_link** : create a softlink to selected file, in the same directory (same name, prefixed by "link to")
  * **pdfimages_extract** : use **pdfimages** command (`poppler-utils` package in Debian) to extract images from PDF and place them in "pdfimages" subdir
  * **pdf_repair** : use **qpdf** command to repair PDF file and create "-repaired.pdf" file
  * **pdf_to_djvu** : use **pdf2djvu** command to convert PDF file to DJVU format

## INSTALL

  - install zenity
  - install lame (to use audio conversion scripts)
  - `bundle install` (this will install Ruby dependencies)
  - link or put files to `~/.local/share/nemo/actions/`
  - restart nemo (`nemo -q`)

## DEBUG

```
nemo -q; NEMO_ACTION_VERBOSE=1 nemo --no-desktop
```

## Write an action

To make scripts executed to multiple files with a progress bar, use `bash_action.rb`. Simple example:
  - execute `ls` command on each selected files:
    `Exec=<scripts/bash_action.rb "ls {}" %F>`
  - same effect, but adding a bash variable:
    `Exec=<scripts/bash_action.rb "filename={}; ls \"$filename\"" %F>`

Take a look to existing actions. Particularly `flac_to_wav.nemo_action` is a simple real-world example.

### Some tricks:
- the space between `"` and `%F>` is important; ie `"%F>` will **not** work

## TODO

  * catch errors and use Zenity to pass error messages to user
