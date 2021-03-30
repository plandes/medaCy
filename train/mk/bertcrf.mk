BERTCRF_NAME=		bert
BERTCRF_PIPE=		$(CONFIG)/$(BERTCRF_NAME).json
BERTCRF_MODEL=		$(BERTCRF_NAME)/model
BERTCRF_METRICS=	$(BERTCRF_NAME)/validate.log
BERTCRF_PKG_DIR=	$(PKG_DIR)/medaCy_bert_model_clinical_notes/medacy_bert_model_clinical_notes
BERTCRF_MODEL_URL=	https://github.com/plandes/medaCy_bert_model_clinical_notes
BERTCRF_PRETRAIN=	"emilyalsentzer/Bio_ClinicalBERT"
BERTCRF_EPOCS=		10

# bert CRF
.PHONY:			bertmodel
bertmodel:		$(BERTCRF_MODEL)
$(BERTCRF_MODEL):	$(CORPUS_TARG)
		mkdir -p $(BERTCRF_NAME)/ground
		$(MEDACY_BIN) -c $(CUDA) -e $(BERTCRF_EPOCS) -crf -d $(CORPUS_TARG) \
			-pm $(BERTCRF_PRETRAIN) \
			-lf $(BERTCRF_NAME)/train.log \
			-cpl $(BERTCRF_PIPE) train -gt $(BERTCRF_NAME)/ground \
			-f $(BERTCRF_MODEL) \
			> $(BERTCRF_NAME)/run.log 2>&1 &

.PHONY:			bertmetrics
bertmetrics:		$(BERTCRF_METRICS)
$(BERTCRF_METRICS):
		@if [ ! -d $(BERTCRF_MODEL) ] ; then \
			echo "model not found: $(BERTCRF_MODEL)" ; \
		fi
		mkdir -p $(BERTCRF_NAME)/preds
		$(MEDACY_BIN) -c $(CUDA) -e $(BERTCRF_EPOCS) -crf -d $(CORPUS_TARG) \
			-pm $(BERTCRF_PRETRAIN) \
			-lf $(BERTCRF_METRICS) \
			-cpl $(BERTCRF_PIPE) validate -k 10 \
			-gt $(BERTCRF_NAME)/ground -pd $(BERTCRF_NAME)/preds \
			> $(BERTCRF_NAME)/run.log 2>&1 &

.PHONY:			bertpkg
bertpkg:
		@if [ ! -f $(BERTCRF_METRICS) ] ; then \
			echo "metrics not found: $(BERTCRF_METRICS)" ; \
		fi
		@if [ ! -d $(BERTCRF_PKG_DIR) ] ; then \
			mkdir -p $(PKG_DIR) ; \
			( cd $(PKG_DIR) ; git clone $(BERTCRF_MODEL_URL) ) ; \
		fi
		$(PKG_BIN) $(BERTCRF_METRICS) $(BERTCRF_MODEL) $(BERTCRF_PKG_DIR) \
			-dstmodel torch

.PHONY:		berttest
berttest:
		$(TEST_BIN) bertcrf -cuda=0
