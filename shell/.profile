export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export HDDTB="$HOME/media/hdd1"
eval "$(pyenv init --path)"


# Load Angular CLI autocompletion.
source <(ng completion script)

case "$(uname -s)" in
	Darwin)
		# cvscode
		export PATH="${HOME}/.local/bin:${PATH}"
		;;
esac
