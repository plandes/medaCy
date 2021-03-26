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
		cp dist/* $(HOME)/opt/lib/python-dist/3.9

.PHONY:		clean
clean:
		python setup.py clean
		rm -fr medacy.egg-info dist build
