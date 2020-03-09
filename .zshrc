# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH=/opt/apache-maven-3.6.3/bin:/Users/chrisathanas/Library/Android/sdk/platform-tools/:$PATH
export PATH=/Users/chrisathanas/Library/Android/sdk/tools/bin/:$PATH
export PATH=/Users/chrisathanas/Library/Python/2.7/bin:$PATH
export JAVA_HOME=$(/usr/libexec/java_home)
export CHEAT_CONFIG_PATH=~/.dotfiles/cheat/conf.yml
# alias clear='[ $[$RANDOM % 10] = 0 ] && sl; clear || clear'
# alias cls='[ $[$RANDOM % 10] = 0 ] && gtimeout 6 cbeams -o; clear || clear'
#alias cls='[ $[$RANDOM % 1] = 0 ] && gtimeout 3 cmatrix; clear || clear'
alias cls=clear

alias mv="mv -i"
alias cp="cp -i"
HISTSIZE=1000000
HISTFILESIZE=100000

# Path to your oh-my-zsh installation.
export ZSH="/Users/chrisathanas/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "avit robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=29

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git 
  zsh-syntax-highlighting 
  zsh-autosuggestions 
  osx
  iterm2
  node
)

ZSH_THEME="powerlevel9k/powerlevel9k"
POWERLEVEL9K_MODE='nerdfont-complete'

zsh_internet_signal(){
  #Try to ping google DNS to see if you have internet
  local net=$(ping 8.8.8.8 -c 1| grep transmitted | awk '{print $7}' | grep 0)
  local color='%F{red}'
  local symbol="\uf127"
  if [[ ! -z "$net" ]] ; 
  then color='%F{green}' ; symbol="\uf1e6" ;
  fi

  echo -n "%{$color%}$symbol" # \f1eb is wifi bars
}

# Get the weather information from https://weatherstack.com/
# Just create a free account to have an API key
# Download jq to convert json
zsh_weather(){
  if [[ -z "$weather_update" ]] ;
    then weather_update=0; # fall thru to initialize
  else 
    local cur_time=$(date +%s)
    if [[ $cur_time -lt $weather_update ]] ;
      then echo -n $weather_current_prompt; return;
    fi
  fi
  weather_update=$[ $(date +%s) + 10 * 60] # set update to 10min from now
 
  local weather=$(curl -s "http://api.weatherstack.com/current?access_key=ff4b9d2dcf8a8bbc22f58d368e269111&query=Austin")
  local temp_c=$(echo $weather | jq .current.temperature)
  local temp_f=$(echo "scale=1; $temp_c * 9 / 5 + 32" | bc)
  local temp_formatted=$(echo "${temp_f}°")
  local condition=$(echo $weather | jq -c .current.weather_descriptions)
  condition=$(echo "$condition" | awk '{print tolower($0)}') 

  # debug to show current conditions
  #echo -n "%F{yellow}${condition}" ; return ;

  local color='%F{green}'
  local symbol=${condition}  # Default to written description

  if [[ $condition == *"rain"* || $condition == *"drizzle"* ]] ;
    then symbol=🌧 ; color='%F{blue}'
  elif [[ $condition == *"cloudy"* || $condition == *"overcast"* ]] ;
    then symbol=☁️ ; color='%F{grey}';
  elif [[ $condition == *"partly"* ]] ;
    then symbol=🌤 ; color='%F{grey}';
  elif [[ $condition == *"sunny"* ]] ;
    then symbol=🌞 ; color='%F{yellow}';
  elif [[ $condition == *"wind"* ]] ;
    then symbol=💨 ; color='%F{white}';
  elif [[ $condition == *"clear"* ]] ;
    then symbol=☀️ ; color='%F{yellow}';
  elif [[ $condition == *"fog"* || $condition == *"mist"* ]] ;
    then symbol=🌫 ; color='%F{white}';
  elif [[ $condition == *"snow"* || $condition == *"pellets"* || $condition == *"sleet"* ]] ;
    then symbol=❄️ ; color='%F{blue}';
  #condition=$(echo "thunder") #commented for testing
  elif [[ $condition == *"thunder"* ]] ;
    then symbol=⛈ ; color='%F{red}';
    if [ $[$RANDOM % 2] = 0 ] ;
      then symbol=⚡️ ;
    fi
    if [ $[$RANDOM % 2] = 0 ] ;
      then symbol=🌩 ;
    fi
  fi

  # Quick return to disable the moon phase
  #echo -n "%{$color%}$temp_formatted$symbol " 
  #return

  #local forecast=$(curl -s "http://api.weatherstack.com/forecast?access_key=ff4b9d2dcf8a8bbc22f58d368e269111&query=austin")
  #local moon_phase=$(echo $forecast | jq '.forecast[].astro.moon_phase')
  #local moon_illum=$(echo $forecast | jq '.forecast[].astro.moon_illumination')

  local forecast_url=$( echo -n "http://api.farmsense.net/v1/moonphases/?d="$(date +%s) )
  local forecast=$(curl -s ${forecast_url})
  local moon_phase=$(echo $forecast | jq '.[0].Phase')
  local moon_illum=$(echo $forecast | jq '.[0].Illumination')
  moon_illum=$(echo "scale=1; $moon_illum * 1000/10" | bc -l)

  local moon_symbol=$moon_phase
  if [[ $moon_phase == *"New Moon"* ]] ;
    then moon_symbol=🌑 ;
  fi
  if [[ $moon_phase == *"Waxing Crescent"* ]] ;
    then moon_symbol=🌒 ;
  fi
  if [[ $moon_phase == *"1st Quarter"* ]] ;
    then moon_symbol=🌓 ;
  fi
  if [[ $moon_phase == *"Waxing Gibbous"* ]] ;
    then moon_symbol=🌔 ;
  fi
  if [[ $moon_phase == *"Full"* ]] ;
    then moon_symbol=🌕 ;
  fi
  if [[ $moon_phase == *"Waning Gibbous"* ]] ;
    then moon_symbol=🌖 ;
  fi
  if [[ $moon_phase == *"3rd Quarter"* ]] ;
    then moon_symbol=🌗 ;
  fi
  if [[ $moon_phase == *"Waning Crescent"* ]] ;
    then moon_symbol=🌘 ;
  fi

  #local high_temp=$(echo $forecast | jq '.forecast[].maxtemp')
  #local low_temp=$(echo $forecast | jq '.forecast[].mintemp') 

  weather_current_prompt="%{$color%}$temp_formatted$symbol  $moon_symbol $moon_illum%%" 
  echo -n $weather_current_prompt
}

preexec() {
  #refresh the weather randomly
zsh_weather > /dev/null ;
}

#POWERLEVEL9K_CUSTOM_INTERNET_SIGNAL="zsh_internet_signal"
POWERLEVEL9K_CUSTOM_INTERNET_SIGNAL_BACKGROUND="black"
POWERLEVEL9K_CUSTOM_WEATHER="zsh_weather"
POWERLEVEL9K_CUSTOM_WEATHER_BACKGROUND="black"
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir newline vcs  )
#POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(custom_internet_signal 
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time background_jobs history custom_weather time)
POWERLEVEL9K_SHORTEN_DIR_LENGTH=5
POWERLEVEL9K_SHORTEN_DELIMITER="\u22EF"
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_from_right"
#POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_right"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=true
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%F{014}\u2570%F{cyan}\u25BA%f "
POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S}"

#source /usr/local/opt/powerlevel9k/powerlevel9k.zsh-theme

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='nano'
# else
#   export EDITOR='vim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="nano ~/.zshrc"
# alias ohmyzsh="nano ~/.oh-my-zsh"
