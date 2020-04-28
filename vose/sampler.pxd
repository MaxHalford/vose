cimport numpy as np

cdef class Sampler:

    cdef int n
    cdef np.int_t [:] alias
    cdef np.float_t [:] proba

    cdef int sample_1(self)
    cdef np.int_t [:] sample_k(self, int k)
