# ═══════════════════════════════════════════════════════════
#  60-cloud.zsh — AWS / Azure / GCP awareness
# ═══════════════════════════════════════════════════════════
#  Nothing here runs on every prompt. The Starship prompt already
#  shows the active profile/account; these helpers are called on
#  demand so that startup stays fast and no network call is made
#  unless you ask for one.
# ═══════════════════════════════════════════════════════════

# ── INI reader ────────────────────────────────────────────
# `_ini_get <file> <key> [section]` returns the first value of
# `key`, optionally restricted to one `[section]`.
#
# Reading a file is instant; `gcloud config get-value` costs a
# Python interpreter start-up and can emit stray output such as
# the literal string "acct=''", so we never shell out here.
_ini_get() {
  local file=$1 key=$2 section=$3
  [[ -r $file ]] || return 1
  local line cur=''
  while IFS= read -r line; do
    line=${line%%#*}                       # drop comments
    line=${line##[[:space:]]##}             # trim leading space
    [[ -z $line ]] && continue
    if [[ $line == \[*\] ]]; then           # [section] header
      cur=${line#\[}
      cur=${cur%\]}
      continue
    fi
    [[ -n $section && $cur != $section ]] && continue
    [[ $line == *=* ]] || continue
    # Key names never contain whitespace, so dropping all of it
    # handles any spacing around the '=' in one step. (zsh's
    # ${k%%[[:space:]]##} does NOT repeat, so it cannot trim.)
    local k=${line%%=*} v=${line#*=}
    k=${k//[[:space:]]/}
    [[ $k == $key ]] || continue
    while [[ $v == [[:space:]]* ]]; do v=${v#?}; done
    while [[ $v == *[[:space:]] ]]; do v=${v%?}; done
    [[ -n $v ]] && { print -r -- "$v"; return 0 }
  done < "$file"
  return 1
}

# ── Shared environment classifier ─────────────────────────
# `cloud-env-report` prints one line per active cloud context,
# flags anything that looks like production, and returns 1 when
# no cloud context is active so callers can say so.
#
# Everything is read from the SDK config files on disk. No
# network call and no subprocess is made, which keeps this safe
# to call at any time.
cloud-env-report() {
  local -i warned=0 found=0
  local line
  # Explicit ANSI: `print` does not expand %F{} escapes and
  # `print -P` would misread a literal % in a profile name.
  local red=$'\e[31m' reset=$'\e[0m'

  # ── AWS ──────────────────────────────────────────────────
  # `AWS_PROFILE` in the environment is authoritative. Fall back
  # to the `default` profile only if ~/.aws/config exists.
  local aws_prof="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-}}"
  [[ -z $aws_prof && -r $HOME/.aws/config ]] && aws_prof=default
  if [[ -n $aws_prof || -n ${AWS_ACCOUNT_ID:-} ]]; then
    found=1
    local aws_acct="${AWS_ACCOUNT_ID:-}"
    local section="profile $aws_prof"
    [[ $aws_prof == default ]] && section=default
    if [[ -z $aws_acct ]]; then
      aws_acct=$(_ini_get $HOME/.aws/config aws_account_id "$section") || aws_acct=""
    fi
    line="aws      profile=$aws_prof  account=${aws_acct:-<unresolved>}"
    if [[ $aws_prof == *prod* || $aws_prof == *production* || $aws_acct == *prod* ]]; then
      print -r -- "${red}  ⚠  PROD${reset}  $line"
      (( warned++ ))
    else
      print -r -- "         $line"
    fi
  fi

  # ── Azure ────────────────────────────────────────────────
  # azureProfile.json is a JSON array of subscription objects.
  local azfile=$HOME/.azure/azureProfile.json
  if (( $+commands[az] )) && [[ -r $azfile ]] && (( $+commands[jq] )); then
    local sub
    sub=$(jq -r 'if type=="array" and length>0
                  then "\(.[0].name // "?")\t\(.[0].id // "")"
                  else "" end' "$azfile" 2>/dev/null)
    if [[ -n $sub ]]; then
      found=1
      # zsh's ${(s:$'\t' :)x} splits on every character, so read
      # the two fields with IFS instead.
      local name id
      IFS=$'\t' read -r name id <<< "$sub"
      line="azure    subscription=${name:-<unknown>}  id=${id[1,6]:-<unknown>}…"
      if [[ $name == *prod* || $name == *production* ]]; then
        print -r -- "${red}  ⚠  PROD${reset}  $line"
        (( warned++ ))
      else
        print -r -- "         $line"
      fi
    fi
  fi

  # ── GCP ──────────────────────────────────────────────────
  # active_config names the active properties set; the values
  # live in configurations/config_<name> as a small INI file.
  local gcpdir=$HOME/.config/gcloud
  if (( $+commands[gcloud] )); then
    local cfgname propfile acct='' proj=''
    if [[ -r $gcpdir/active_config ]]; then
      cfgname=$(<$gcpdir/active_config)
      cfgname=${cfgname//[[:space:]]/}       # drop the trailing newline
      propfile=$gcpdir/configurations/config_${cfgname:-default}
    else
      propfile=$gcpdir/configurations/config_default
    fi
    [[ -r $propfile ]] && {
      acct=$(_ini_get $propfile account) || acct=''
      proj=$(_ini_get $propfile project) || proj=''
    }
    acct=${acct#\(unset\)}
    proj=${proj#\(unset\)}
    if [[ -n $acct || -n $proj ]]; then
      found=1
      line="gcp      account=${acct:-<none>}  project=${proj:-<none>}"
      if [[ $acct == *prod* || $proj == *prod* ]]; then
        print -r -- "${red}  ⚠  PROD${reset}  $line"
        (( warned++ ))
      else
        print -r -- "         $line"
      fi
    fi
  fi

  if (( ! found )); then
    return 1
  fi
  if (( warned )); then
    print -r -- ""
    print -u2 "Production context active. Double-check --profile/--subscription/--project on every command."
  fi
  return 0
}

# ── AWS shortcuts ─────────────────────────────────────────
if have aws; then
  # Identity of the *current* credentials, resolved for real.
  alias awswho='aws sts get-caller-identity'
  alias awsregions='aws ec2 describe-regions --query "Regions[].RegionName" --output text | tr "\t" "\n"'
  alias awsprofiles='aws configure list-profiles'
  # Guarded: the previous config had no protection at all.
  awsprod-guard() {
    if [[ "${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-}}" != *prod* ]]; then
      print -u2 "Refusing: AWS_PROFILE is '${AWS_PROFILE:-<default>}', which does not look like production."
      print -u2 "Set it explicitly if this is wrong:  AWS_PROFILE=prod awsprod $1"
      return 1
    fi
    command aws "$@"
  }
fi

# ── Azure shortcuts ───────────────────────────────────────
if have az; then
  alias azwho='az account show -o table'
  alias azsubs='az account list -o table'
  # `azx` runs an az command against the named subscription, so the
  # target is always stated in the history line.
  azx() {
    local sub=$1; shift
    print -u2 "az account set --subscription $sub"
    az account set --subscription "$sub" && az "$@"
  }
fi

# ── GCP shortcuts ─────────────────────────────────────────
if have gcloud; then
  alias gwho='gcloud auth list'
  alias gprojects='gcloud projects list'
  gpx() {
    local proj=$1; shift
    print -u2 "gcloud config set project $proj"
    gcloud config set project "$proj" && gcloud "$@"
  }
fi
