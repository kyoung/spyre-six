SHELL := /bin/bash

.PHONY: client
client:
	elm-make src/Main.elm --output=build/main.js
