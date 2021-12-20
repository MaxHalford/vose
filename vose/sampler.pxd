cimport numpy as np
from random_wrapper cimport mt19937_64, uniform_real_distribution


cdef class Sampler:

    cdef int n
    cdef mt19937_64 generator
    cdef uniform_real_distribution[double] dist
    cdef np.int_t [:] alias
    cdef np.float_t [:] proba
    cdef bint coin_toss(self, float p)
    cdef int fair_die(self, int n)

    cdef int sample_1(self)
    cdef np.int_t [:] sample_k(self, int k)
