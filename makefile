all:		install

.PHONY:		uninstall
uninstall:
		( cd ~/ ; pip uninstall -y medacy )

.PHONY:		install
install:	uninstall build
		( cd dist ; pip install * )

.PHONY:		reinstall
reinstall:	install

.PHONY:		build
build:		clean
		python setup.py bdist_wheel

.PHONY:		clean
clean:
		python setup.py clean
		rm -fr medacy.egg-info dist build
		find . -type d -name __pycache__ -prune -exec rm -r {} \;
