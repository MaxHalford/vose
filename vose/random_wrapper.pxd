# distutils: language = c++
# distutils: extra_compile_args = -std=c++11

cdef extern from "<random>" namespace "std":
    cdef cppclass minstd_rand:
        minstd_rand() # we need to define this constructor to stack allocate classes in Cython
        minstd_rand(unsigned int seed) # not worrying about matching the exact int type for seed
        unsigned int operator()()
        unsigned int max()

    cdef cppclass random_device:
        random_device() # we need to define this constructor to stack allocate classes in Cython
        unsigned int operator()()