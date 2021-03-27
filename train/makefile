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
CRF_NAME=	crf
CRF_PIPE=	$(CONFIG)/$(CRF_NAME).json
CRF_MODEL=	$(CRF_NAME)/model.pkl
CRF_METRICS=	$(CRF_NAME)/validate.log
CRF_PKG_DIR=	$(PKG_DIR)/medaCy_model_clinical_notes/medacy_model_clinical_notes
CRF_MODEL_URL=	https://github.com/NLPatVCU/medaCy_model_clinical_notes

BERT_NAME=	bert
BERT_PIPE=	$(CONFIG)/$(BERT_NAME).json
BERT_MODEL=	$(BERT_NAME)/model
BERT_METRICS=	$(BERT_NAME)/validate.log
BERT_PKG_DIR=	$(PKG_DIR)/medaCy_bert_model_clinical_notes/medacy_bert_model_clinical_notes
BERT_MODEL_URL=	https://github.com/plandes/medaCy_bert_model_clinical_notes


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

# CRF
.PHONY:		crfmodel
crfmodel:	$(CRF_MODEL)
$(CRF_MODEL):	$(CORPUS_TARG)
		mkdir -p $(CRF_NAME)/ground
		$(MEDACY_BIN) -c $(CUDA) -d $(CORPUS_TARG) \
			-lf $(CRF_NAME)/train.log \
			-cpl $(CRF_PIPE) train -gt $(CRF_NAME)/ground \
			-f $(CRF_MODEL) > $(CRF_NAME)/run.log 2>&1 &

.PHONY:		crfmetrics
crfmetrics:	$(CRF_METRICS)
$(CRF_METRICS):
		@if [ ! -f $(CRF_MODEL) ] ; then \
			echo "model not found: $(CRF_MODEL)" ; \
		fi
		mkdir -p $(CRF_NAME)/preds
		$(MEDACY_BIN) -c $(CUDA) -d $(CORPUS_TARG) \
			-lf $(CRF_METRICS) \
			-cpl $(CRF_PIPE) validate -k 10 \
			-gt $(CRF_NAME)/ground -pd $(CRF_NAME)/preds \
			> $(CRF_NAME)/run.log 2>&1 &

.PHONY:		crfpkg
crfpkg:
		@if [ ! -f $(CRF_METRICS) ] ; then \
			echo "metrics not found: $(CRF_METRICS)" ; \
		fi
		@if [ ! -d $(CRF_PKG_DIR) ] ; then \
			mkdir -p $(PKG_DIR) ; \
			( cd $(PKG_DIR) ; git clone $(CRF_MODEL_URL) ) ; \
		fi
		$(PKG_BIN) $(CRF_METRICS) $(CRF_MODEL) $(CRF_PKG_DIR)


.PHONY:		crftest
crftest:
		$(TEST_BIN) crf

# bert CRF
.PHONY:		bertmodel
bertmodel:	$(BERT_MODEL)
$(BERT_MODEL):	$(CORPUS_TARG)
		mkdir -p $(BERT_NAME)/ground
		$(MEDACY_BIN) -c $(CUDA) -e 10 -crf -d $(CORPUS_TARG) \
			-pm 'emilyalsentzer/Bio_ClinicalBERT' \
			-lf $(BERT_NAME)/train.log \
			-cpl $(BERT_PIPE) train -gt $(BERT_NAME)/ground \
			-f $(BERT_MODEL) \
			> $(BERT_NAME)/run.log 2>&1 &

.PHONY:		bertmetrics
bertmetrics:	$(BERT_METRICS)
$(BERT_METRICS):
		@if [ ! -d $(BERT_MODEL) ] ; then \
			echo "model not found: $(BERT_MODEL)" ; \
		fi
		mkdir -p $(BERT_NAME)/preds
		$(MEDACY_BIN) -c $(CUDA) -e 10 -crf -d $(CORPUS_TARG) \
			-pm 'emilyalsentzer/Bio_ClinicalBERT' \
			-lf $(BERT_METRICS) \
			-cpl $(BERT_PIPE) validate -k 10 \
			-gt $(BERT_NAME)/ground -pd $(BERT_NAME)/preds \
			> $(BERT_NAME)/run.log 2>&1 &

.PHONY:		bertpkg
bertpkg:
		@if [ ! -f $(BERT_METRICS) ] ; then \
			echo "metrics not found: $(BERT_METRICS)" ; \
		fi
		@if [ ! -d $(BERT_PKG_DIR) ] ; then \
			mkdir -p $(PKG_DIR) ; \
			( cd $(PKG_DIR) ; git clone $(BERT_MODEL_URL) ) ; \
		fi
		$(PKG_BIN) $(BERT_METRICS) $(BERT_MODEL) $(BERT_PKG_DIR) \
			-dstmodel torch

.PHONY:		berttest
berttest:
		$(TEST_BIN) bertcrf -cuda=0


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
