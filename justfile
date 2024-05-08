format:
    mix format

setup:
    mix deps.get

run +args='':
    iex -S mix {{args}}

test:
    mix test

check:
    just format
    mix credo --mute-exit-status
    mix dialyzer
    just test

destory:
    just clean

clean:
    mix clean
    rm -rf deps _build
