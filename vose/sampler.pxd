cimport numpy as np
from random_wrapper cimport minstd_rand


cdef class Sampler:

    cdef int n
    cdef minstd_rand generator
    cdef int maxi
    cdef np.int_t [:] alias
    cdef np.float_t [:] proba
    cdef bint coin_toss(self, float p)
    cdef int fair_die(self, int n)

    cdef int sample_1(self)
    cdef np.int_t [:] sample_k(self, int k)
