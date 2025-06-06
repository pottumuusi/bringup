pushd $(dirname $0)

readonly VENV_DIRECTORY=".venv"
readonly BRINGUP_BASE_PATH="$(pushd ../ &> /dev/null; pwd ; popd &> /dev/null)"

popd # $(dirname $0)
