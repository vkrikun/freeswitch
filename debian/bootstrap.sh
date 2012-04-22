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
Depends: \${shlibs:Depends}, \${misc:Depends}
Recommends: freeswitch-lang-en
Suggests:
Description: Cross-Platform Scalable Multi-Protocol Soft Switch
 ${fs_description}
 .
 This package contains the FreeSWITCH core.

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
Depends: \${shlibs:Depends}, \${misc:Depends}, freeswitch
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

## sounds

Package: freeswitch-sounds-en-us
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, freeswitch-sounds-en-us-callie
Description: US English sounds for FreeSWITCH
 ${fs_description}
 .
 This package contains the English sounds for FreeSWITCH.

Package: freeswitch-sounds-en-us-callie
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}
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
  local mod="$3"
  (print_edit_warning; print_mod_install "$mod") > freeswitch-${mod//_/-}.install
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

