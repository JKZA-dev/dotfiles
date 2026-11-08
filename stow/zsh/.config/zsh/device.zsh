# device_model [--refresh|--no-cache]: prints "Vendor Model" of this machine.
# Cached: system_profiler is slow and the hardware does not change.

_device_junk=(none unknown n/a 'not specified' 'not applicable' 'default string'
  'to be filled by o.e.m.' o.e.m. 'system product name' 'system manufacturer' 'system version')

_device_clean() {
  setopt local_options extended_glob
  local value=${${1##[[:space:]]#}%%[[:space:]]#}
  (( ${_device_junk[(Ie)${(L)value}]} )) || print -r -- $value
}

# Skips the vendor when the model already starts with it ("Lenovo ThinkPad").
_device_join() {
  local vendor=$(_device_clean $1) model=$(_device_clean $2)
  if [[ -z $vendor || -z $model || ${(L)model} == ${(L)vendor}* ]]; then
    print -r -- ${model:-$vendor}
  else
    print -r -- "$vendor $model"
  fi
}

_device_detect_darwin() {
  local name=${${(M)${(f)"$(system_profiler SPHardwareDataType 2>/dev/null)"}:#*Model Name:*}##*: }
  local ident=$(sysctl -n hw.model 2>/dev/null)
  [[ -n $name$ident ]] && print -r -- "Apple ${name:-$ident}${name:+${ident:+ ($ident)}}"
}

_device_detect_linux() {
  local dmi=/sys/class/dmi/id result file
  [[ -r $dmi/product_name && -r $dmi/sys_vendor ]] && result=$(_device_join "$(<$dmi/sys_vendor)" "$(<$dmi/product_name)")

  # ARM boards have no DMI.
  for file in /sys/firmware/devicetree/base/model /proc/device-tree/model; do
    [[ -z $result && -r $file ]] && result=$(_device_clean "${$(<$file)//$'\0'/}")
  done

  if [[ -z $result ]] && (( $+commands[hostnamectl] )); then
    local -a info=("${(@f)$(hostnamectl 2>/dev/null)}")
    result=$(_device_join "${${(M)info:#*Hardware Vendor:*}##*: }" "${${(M)info:#*Hardware Model:*}##*: }")
  fi
  [[ -n $result ]] && print -r -- $result
}

device_model() {
  local cache=${XDG_CACHE_HOME:-$HOME/.cache}/device-model device
  if [[ -z $1 && -s $cache ]]; then
    print -r -- "$(<$cache)"
    return
  fi

  case $OSTYPE in
    darwin*) device=$(_device_detect_darwin) ;;
    linux*)  device=$(_device_detect_linux) ;;
  esac
  : ${device:="$(uname -s) $(uname -m)"}

  [[ $1 == --no-cache ]] || { mkdir -p ${cache:h} && print -r -- $device >| $cache } 2>/dev/null
  print -r -- $device
}
