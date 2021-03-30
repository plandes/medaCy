BERT_NAME=	bert
BERT_PIPE=	$(CONFIG)/$(BERT_NAME).json
BERT_MODEL=	$(BERT_NAME)/model
BERT_METRICS=	$(BERT_NAME)/validate.log
BERT_PKG_DIR=	$(PKG_DIR)/medaCy_bert_model_clinical_notes/medacy_bert_model_clinical_notes
BERT_MODEL_URL=	https://github.com/plandes/medaCy_bert_model_clinical_notes
BERT_PRETRAIN=	'emilyalsentzer/Bio_ClinicalBERT'
BERT_EPOCS=	3

# bert CRF
.PHONY:		bertmodel
bertmodel:	$(BERT_MODEL)
$(BERT_MODEL):	$(CORPUS_TARG)
		mkdir -p $(BERT_NAME)/ground
		$(MEDACY_BIN) -c $(CUDA) -e $(BERT_EPOCS) -d $(CORPUS_TARG) \
			-pm $(BERT_PRETRAIN) \
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
		$(MEDACY_BIN) -c $(CUDA) -e $(BERT_EPOCS) -d $(CORPUS_TARG) \
			-pm $(BERT_PRETRAIN) \
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
