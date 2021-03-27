# Build Medacy Models

The [makefile](makefile), set of scripts and configuration files in this
subtree trains models for the [medaCy] project.  The models include:

* The previous [clinical model]
* A new [BERT model] trained on the [ClinicalBERT] pre-trained vectors.


## Usage


To build the [clinical model]:
1. Train the model: `make crfmodel`
2. Wait a long time.
3. Validate the model to get the stats: `make crfmetrics`
4. Copy the model and the performance metrics from the validation log to the
   git repo: `make crfpkg`.
5. Build/install the model: `( cd model_repos/medaCy_model_clinical_notes ;
   make reinstall && git commit -am 'model trained' )`
6. Run the model: `make crftest`

To build the [BERT model]:
1. Train the model: `make bertmodel`
2. Wait a long time.
3. Validate the model to get the stats: `make bertmetrics`
4. Copy the model and the performance metrics from the validation log to the
   git repo: `make bertpkg`.
5. Build/install the model: `( cd model_repos/medaCy_bert_model_clinical_notes ;
   make reinstall && git commit -am 'model trained' )`
6. Run the model: `make berttest`


<!-- links -->
[clinical model]: https://github.com/NLPatVCU/medaCy_model_clinical_notes/
[BERT model]: https://github.com/plandes/medaCy_bert_model_clinical_notes
[medaCy]: https://github.com/NLPatVCU/medaCy
[ClinicalBERT]: https://huggingface.co/emilyalsentzer/Bio_ClinicalBERT
