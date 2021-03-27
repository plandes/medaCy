#!/usr/bin/env python

import plac
from medacy.model.model import Model


@plac.annotations(
    model=('The model to test', 'positional', None, str, ['crf', 'bertcrf']),
    text=('The text to parse for annotations.', 'option', None, str),
    cuda=('The CUDA device to use.', 'option', None, int))
def main(model: str, text: str = None, cuda: int = None):
    if text is None:
        text = "The patient was prescribed 1 capsule of Advil for five days."
    if model == 'crf':
        print('using CRF model')
        model = Model.load_external('medacy_model_clinical_notes')
    else:
        print('using BERT model')
        if cuda is not None:
            from medacy_bert_model_clinical_notes import medacy_bert_model_clinical_notes
            medacy_bert_model_clinical_notes.PIPELINE_ARGS['cuda_device'] = cuda
        model = Model.load_external('medacy_bert_model_clinical_notes')
    anons = model.predict(text)
    for anon in anons:
        print(anon)


if __name__ == '__main__':
    plac.call(main)
