## bulid for creating clinical model


## build

# general
CUDA=		0
MEDACY_BIN=	nohup python -m medacy
# corpus
CORPUS_SRC=	$(HOME)/opt/nlp/corpora/org/medical/n2c2/2018-ade-medication-track-2
CORPUS_TARG=	clinical-corp
# paths
LOG=		medacy_0.log 
CONFIG=		conf

# model packages
PKG_BIN=	python src/mkpkg.py
PKG_DIR ?=	model_repos

# testing
TEST_BIN=	python src/test.py


# models
include mk/crf.mk
include mk/bert.mk


## targets
all:		build

.PHONY:		help
help:
		$(MEDACY_BIN) -h
		cat nohup.out

.PHONY:		corpus
corpus:		$(CORPUS_TARG)

$(CORPUS_TARG):
		@echo "uncompressing corpus"
		ls $(CORPUS_SRC)
		cp $(CORPUS_SRC)/gold-standard-test-data.zip .
		cp $(CORPUS_SRC)/training_20180910.zip .
		unzip gold-standard-test-data.zip
		unzip training_20180910.zip
		mv test $(CORPUS_TARG)
		mv -i training_20180910/* $(CORPUS_TARG)
		rm -r *.zip __MACOSX training_20180910

# clean
.PHONY:		clean
clean:
		rm -rf *.log *.pkl nohup.out

.PHONY:		cleanmodels
cleanmodels:	clean
		rm -fr $(CRF_NAME) $(BERT_NAME)

.PHONY:		cleanall
cleanall:	cleanmodels
		rm -rf $(CORPUS_TARG) $(PKG_DIR)
