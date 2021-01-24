if [ "${BASH_SOURCE[0]}" != "" ]; then
  self="${BASH_SOURCE[0]}"
else
  self="$0"
fi

export ELASTIC_DIR
ELASTIC_DIR="$(dirname "$self")"

ELASTIC_BIN="${ELASTIC_DIR}/bin"
[[ ":$PATH:" == *":${ELASTIC_BIN}:"* ]] || PATH="${ELASTIC_BIN}:$PATH"
