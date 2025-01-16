cimport numpy as np

from libcpp.random cimport mt19937
from libcpp.random cimport uniform_real_distribution
from libcpp.random cimport uniform_int_distribution

cdef class Sampler:

    cdef int n
    cdef np.int64_t [:] alias
    cdef np.float_t [:] proba
    cdef mt19937 rng
    cdef uniform_int_distribution[int] fair_die
    cdef uniform_real_distribution[double] coin_toss

    cdef int sample_1(self)
    cdef np.int64_t [:] sample_k(self, int k)
