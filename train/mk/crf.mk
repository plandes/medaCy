CRF_NAME=	crf
CRF_PIPE=	$(CONFIG)/$(CRF_NAME).json
CRF_MODEL=	$(CRF_NAME)/model.pkl
CRF_METRICS=	$(CRF_NAME)/validate.log
CRF_PKG_DIR=	$(PKG_DIR)/medaCy_model_clinical_notes/medacy_model_clinical_notes
CRF_MODEL_URL=	https://github.com/NLPatVCU/medaCy_model_clinical_notes

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
