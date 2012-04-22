#!/bin/bash

mod_dir="../src/mod/"
fs_description="FreeSWITCH is a scalable open source cross-platform telephony platform designed to route and interconnect popular communication protocols using audio, video, text or any other form of media."
avoid_mods=(
  applications/mod_fax
  applications/mod_ladspa
  applications/mod_mp4
  applications/mod_osp
  applications/mod_rad_auth
  applications/mod_skel
  asr_tts/mod_cepstral
  codecs/mod_com_g729
  codecs/mod_sangoma_codec
  codecs/mod_skel_codec
  endpoints/mod_gsmopen
  endpoints/mod_h323
  endpoints/mod_khomp
  endpoints/mod_opal
  endpoints/mod_reference
  endpoints/mod_unicall
  event_handlers/mod_snmp
  formats/mod_vlc
  languages/mod_java
  languages/mod_managed
  languages/mod_yaml
  sdk/autotools
)

avoid_mod_filter () {
  for x in "${avoid_mods[@]}"; do
    [ "$1" = "$x" ] && return 1
  done
  return 0
}

modconf_filter () {
  while read line; do
    [ "$1" = "$line" ] && return 0
  done < modules.conf
  return 1
}

mod_filter () {
  if test -f modules.conf; then
    modconf_filter $@
  else
    avoid_mod_filter $@
  fi
}

map_modules () {
  local filterfn="$1" percatfns="$2" permodfns="$3"
  for x in $mod_dir/*; do
    if test -d $x; then
      local category=${x##*/}
      for f in $percatfns; do $f "$category" "$x"; done
      for y in $x/*; do
        local mod=${y##*/} title="" description=""
        if $filterfn $category/$mod; then
          [ -f ${y}/module ] && . ${y}/module
          [ -n "$title" ] || title="$mod"
          [ -n "$description" ] || description="Adds ${mod}."
          for f in $permodfns; do
            $f "$category" "$x" "$mod" "$y" "$title" "$description"
          done
        fi
      done
    fi
  done
}

print_core_control () {
cat <<EOF
Package: freeswitch
Architecture: any
Depends: \${shlibs:Depends}, \${perl:Depends}, \${misc:Depends}
Recommends:
Suggests:
Description: Cross-Platform Scalable Multi-Protocol Soft Switch
 ${fs_description}
 .
 This package contains the FreeSWITCH core.

Package: freeswitch-meta-default
Architecture: any
Depends: \${misc:Depends}, freeswitch (= \${binary:Version}),
 freeswitch-mod-commands (= \${binary:Version}),
 freeswitch-mod-conference (= \${binary:Version}),
 freeswitch-mod-db (= \${binary:Version}),
 freeswitch-mod-dptools (= \${binary:Version}),
 freeswitch-mod-fifo (= \${binary:Version}),
 freeswitch-mod-hash (= \${binary:Version}),
 freeswitch-mod-spandsp (= \${binary:Version}),
 freeswitch-mod-voicemail (= \${binary:Version}),
 freeswitch-mod-dialplan-xml (= \${binary:Version}),
 freeswitch-mod-loopback (= \${binary:Version}),
 freeswitch-mod-sofia (= \${binary:Version}),
 freeswitch-mod-local-stream (= \${binary:Version}),
 freeswitch-mod-native-file (= \${binary:Version}),
 freeswitch-mod-tone-stream (= \${binary:Version}),
 freeswitch-mod-lua (= \${binary:Version}),
 freeswitch-mod-console (= \${binary:Version}),
 freeswitch-mod-say-en (= \${binary:Version})
Recommends:
 freeswitch-meta-codecs (= \${binary:Version}),
 freeswitch-sounds-music (= \${binary:Version}),
 freeswitch-sounds-en-us (= \${binary:Version})
Suggests:
 freeswitch-mod-cidlookup (= \${binary:Version}),
 freeswitch-mod-curl (= \${binary:Version}),
 freeswitch-mod-directory (= \${binary:Version}),
 freeswitch-mod-enum (= \${binary:Version}),
 freeswitch-mod-spy (= \${binary:Version}),
 freeswitch-mod-valet-parking (= \${binary:Version})
Description: Cross-Platform Scalable Multi-Protocol Soft Switch
 ${fs_description}
 .
 This is a meta package containing a reasonable basic FreeSWITCH
 install.

Package: freeswitch-meta-codecs
Architecture: any
Depends: \${misc:Depends}, freeswitch (= \${binary:Version}),
 freeswitch-mod-amr (= \${binary:Version}),
 freeswitch-mod-amrwb (= \${binary:Version}),
 freeswitch-mod-bv (= \${binary:Version}),
 freeswitch-mod-celt (= \${binary:Version}),
 freeswitch-mod-codec2 (= \${binary:Version}),
 freeswitch-mod-g723-1 (= \${binary:Version}),
 freeswitch-mod-g729 (= \${binary:Version}),
 freeswitch-mod-h26x (= \${binary:Version}),
 freeswitch-mod-ilbc (= \${binary:Version}),
 freeswitch-mod-mp4v (= \${binary:Version}),
 freeswitch-mod-opus (= \${binary:Version}),
 freeswitch-mod-silk (= \${binary:Version}),
 freeswitch-mod-siren (= \${binary:Version}),
 freeswitch-mod-speex (= \${binary:Version}),
 freeswitch-mod-theora (= \${binary:Version})
Description: Cross-Platform Scalable Multi-Protocol Soft Switch
 ${fs_description}
 .
 This is a meta package containing most FreeSWITCH codecs.

Package: freeswitch-dbg
Section: debug
Architecture: any
Depends: \${misc:Depends}, freeswitch (= \${binary:Version})
Description: debugging symbols for FreeSWITCH
 ${fs_description}
 .
 This package contains debugging symbols for FreeSWITCH.

Package: freeswitch-dev
Section: libdevel
Architecture: any
Depends: \${misc:Depends}, freeswitch
Description: development libraries and header files for FreeSWITCH
 ${fs_description}
 .
 This package contains include files for FreeSWITCH.

Package: freeswitch-doc
Architecture: all
Description: documentation for FreeSWITCH
 ${fs_description}
 .
 This package contains Doxygen-produce documentation for FreeSWITCH.

Package: freeswitch-sysvinit
Architecture: all
Depends: \${misc:Depends}
Description: FreeSWITCH SysV init script
 ${fs_description}
 .
 This package contains the SysV init script for FreeSWITCH.

## misc

Package: freeswitch-htdocs-slim
Architecture: all
Depends: \${misc:Depends}
Description: FreeSWITCH htdocs slim player
 ${fs_description}
 .
 This package contains the slim SWF player for FreeSWITCH.

## sounds

Package: freeswitch-sounds-music
Architecture: all
Depends: \${misc:Depends}
Description: Music on hold audio for FreeSWITCH
 ${fs_description}
 .
 This package contains the default music on hold audio for FreeSWITCH.

Package: freeswitch-sounds-en-us
Architecture: all
Depends: \${misc:Depends},
 freeswitch-sounds-en-us-callie (= \${binary:Version})
Description: US English sounds for FreeSWITCH
 ${fs_description}
 .
 This package contains the English sounds for FreeSWITCH.

Package: freeswitch-sounds-en-us-callie
Architecture: all
Depends: \${misc:Depends}
Description: US English sounds for FreeSWITCH
 ${fs_description}
 .
 This package contains the Callie English sounds for FreeSWITCH.

EOF
}

print_mod_control () {
  local mod="$1" title="$2" descr="$3"
  cat <<EOF
Package: freeswitch-${mod//_/-}
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}, freeswitch
Description: ${title} for FreeSWITCH
 ${fs_description}
 .
 This package contains ${mod} for FreeSWITCH.
 .
 ${descr}

EOF
}

print_mod_install () {
  cat <<EOF
/usr/lib/freeswitch/mod/${1}.{la,so}
EOF
}

print_edit_warning () {
  echo "#### Do not edit!  This file is auto-generated from debian/bootstrap.sh."; echo
}

gencontrol_per_mod () {
  local mod="$3" title="$5" descr="$6"
  print_mod_control "$mod" "$title" "$descr" >> control  
}

gencontrol_per_cat () {
  (echo "## mod/$1"; echo) >> control
}

geninstall_per_mod () {
  local mod="$3" f=freeswitch-${mod//_/-}.install
  (print_edit_warning; print_mod_install "$mod") > $f
  test -f $f.tmpl && cat $f.tmpl >> $f
}

genmodules_per_cat () {
  echo "# $1" >> ../modules.conf
}

genmodules_per_mod () {
  local cat="$1" mod="$3"
  echo "$cat/$mod" >> ../modules.conf
}

print_edit_warning > ../modules.conf
(cat control.tmpl; print_edit_warning; print_core_control;
  echo "### modules"; echo) > control
map_modules "mod_filter" \
  "gencontrol_per_cat genmodules_per_cat" \
  "gencontrol_per_mod geninstall_per_mod genmodules_per_mod"

