#!/usr/bin/env python3

import os
from setuptools import Extension
from setuptools import setup
from Cython.Build import cythonize
import numpy as np


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


setup(
    name='vose',
    version='0.1.0',
    author='Max Halford',
    license='MIT',
    author_email='maxhalford25@gmail.com',
    description="Cython implementation of Vose's Alias method.",
    long_description=read('README.md'),
    long_description_content_type='text/markdown',
    url='https://github.com/MaxHalford/vose',
    packages=['vose'],
    install_requires=['numpy'],
    extras_require={'dev': ['pytest', 'scipy']},
    python_requires='>=3.10',
    ext_modules=cythonize(
        [
            Extension(
                '*', ['vose/sampler.pyx'],
                include_dirs=[np.get_include()],
                define_macros=[('NPY_NO_DEPRECATED_API', 'NPY_1_7_API_VERSION')],
                language='c++',
                extra_compile_args=['-std=c++11'],
                extra_link_args=['-std=c++11'],
            ),
        ],
        compiler_directives={'language_level': 2}
    ),
    package_data={'vose': ['*.pxd']},
)
