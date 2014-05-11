$name=$args[0]
cls

elm --make `
	--runtime=dependencies/elm-runtime.js `
	--build-dir=. `
	--cache-dir=cache `
	$name