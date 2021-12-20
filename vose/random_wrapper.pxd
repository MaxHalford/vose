# distutils: language = c++
# distutils: extra_compile_args = -std=c++11

cdef extern from "<random>" namespace "std":
    cdef cppclass mt19937_64:
        mt19937_64() # we need to define this constructor to stack allocate classes in Cython
        mt19937_64(unsigned int seed) # not worrying about matching the exact int type for seed

    cdef cppclass random_device:
        random_device() # we need to define this constructor to stack allocate classes in Cython
        unsigned int operator()()
    
    cdef cppclass uniform_real_distribution[T]:
        uniform_real_distribution()
        uniform_real_distribution(T a, T b)
        T operator()(mt19937_64 gen) # ignore the possibility of using other classes for "gen"