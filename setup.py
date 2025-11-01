from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np

# Build Cython extensions
extensions = cythonize([
    Extension(
        "*",
        ["vose/sampler.pyx"],
        include_dirs=[np.get_include()],
        define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")]
    )
],
compiler_directives={"language_level": 2})

# setuptools will read metadata from pyproject.toml
setup(
    ext_modules=extensions,
    package_data={"vose": ["*.pxd"]},
)
