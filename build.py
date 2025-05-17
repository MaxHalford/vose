from setuptools import Extension
from Cython.Build import cythonize
import numpy as np

def build(setup_kwargs):
    extensions = cythonize([
        Extension(
            "*",
            ["vose/sampler.pyx"],
            include_dirs=[np.get_include()],
            define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")]
        )
    ],
    compiler_directives={"language_level": 2})

    setup_kwargs.update({
        "ext_modules": extensions,
        "package_data": {"vose": ["*.pxd"]},
    })
