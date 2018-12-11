build:
	claat export --prefix "../" -o docs ${NAME}
	cd docs && claat build

