#!/usr/bin/env python

from typing import List
from dataclasses import dataclass
import logging
from pathlib import Path
import shutil
import plac

logger = logging.getLogger(__name__)


@dataclass
class MakePackage(object):
    metrics: Path
    src_model: Path
    dst_model: str
    package: Path

    def get_metrics(self) -> str:
        logger.info(f'parsing validation file for output metrics: {self.metrics}')
        is_mets = False
        mets: List[str]
        with open(self.metrics) as f:
            for line in map(lambda ln: ln.strip(), f.readlines()):
                if line == 'CustomPipeline':
                    is_mets = True
                    mets = []
                elif line.find('Overwriting file') > -1:
                    is_mets = False
                elif is_mets:
                    mets.append(line)
        return '\n'.join(mets)

    def install(self):
        model_path = self.package / 'model'
        metrics_path = model_path / 'model_data.txt'
        logger.info(f'copying metrics to {metrics_path}')
        if not metrics_path.is_file():
            raise ValueError(
                f'expecting to overrite metrics file: {metrics_path}')
        with open(metrics_path, 'w') as f:
            f.write(self.get_metrics())
        src_model = self.src_model
        if src_model.is_file():
            dst_model = model_path / 'n2c2_model.pkl'
            logger.info(f'copying model from {src_model} to {dst_model}')
            if not dst_model.is_file():
                raise ValueError(f'expecting model to exist in {dst_model}')
            shutil.copyfile(src_model, dst_model)
        else:
            dst_model = model_path
            if self.dst_model is not None:
                dst_model = dst_model / self.dst_model
            if not dst_model.is_dir():
                raise ValueError(f'expecting model to exist in {dst_model}')
            logger.info(f'copying model from {src_model} to {dst_model}')
            shutil.rmtree(dst_model)
            shutil.copytree(src_model, dst_model)


@plac.annotations(
    metrics=('The path to the validation log file.', 'positional', None, Path),
    srcmodel=('The path to the source model.', 'positional', None, Path),
    dstmodel=('The diredtory name to the destination model.', 'option', None, str),
    package=('The path to the package directory', 'positional', None, Path))
def main(metrics: Path, srcmodel: Path, package: Path, dstmodel: str = None):
    logging.basicConfig(level=logging.INFO, format='%(message)s')
    mpkg = MakePackage(metrics, srcmodel, dstmodel, package)
    mpkg.install()


if __name__ == '__main__':
    plac.call(main)
