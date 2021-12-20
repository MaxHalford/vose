# distutils: language = c++
# cython: boundscheck=False
# cython: wraparound=False
# cython: initializedcheck=False
# cython: cdivision=True

import numpy as np

from libcpp.deque cimport deque
cimport cython
cimport numpy as np

from random_wrapper cimport minstd_rand, random_device

__all__ = ['Sampler']



cdef class Sampler:
    """Vose's Alias Method.

    This is a data structure that allows sampling random integers with replacement in O(1) time. It
    is initialized with a set of n weights in O(n) time.

    Parameters:
        weights: A memoryview of weights. The weights are not required to sum up to 1.
        copy: Whether or not to copy the provided weights. Setting this to `False` will save some
            time during the initialization phase, but will modify the provided weights.
        seed: An integer used for reproducibility.

    """

    def __init__(self, np.float_t [:] weights not None, copy=True, seed=None):

        cdef random_device r
        if seed is None:
            self.generator = minstd_rand(r())
        else:
            self.generator = minstd_rand(seed)

        self.maxi = self.generator.max()

        if copy:
            weights = weights.copy()

        cdef int n = weights.size
        cdef np.int_t [:] alias = np.zeros(n, dtype=int)
        cdef np.float_t [:] proba = np.zeros(n, dtype=float)

        # Compute the average probability and cache it for later use.
        cdef np.float_t avg = 1. / n

        # Create two stacks to act as worklists as we populate the tables.
        cdef deque[int] small = deque[int]()
        cdef deque[int] large = deque[int]()

        # Populate the stacks with the input probabilities.
        cdef int i
        for i in range(n):
            # If the probability is below the average probability, then we add it to the small
            # list; otherwise we add it to the large list.
            if weights[i] >= avg:
                large.push_front(i)
            else:
                small.push_front(i)

        # As a note: in the mathematical specification of the algorithm, we will always exhaust the
        # small list before the big list. However, due to floating point inaccuracies, this is not
        # necessarily true. Consequently, this inner loop (which tries to pair small and large
        # elements) will have to check that both lists aren't empty.
        cdef int less
        cdef int more
        while not small.empty() and not large.empty():

            # Get the index of the small and the large probabilities.
            less = small.back(); small.pop_back()
            more = large.back(); large.pop_back()

            # These probabilities have not yet been scaled up to be such that 1 / n is given weight
            # 1.0. We do this here instead.
            proba[less] = weights[less] * n
            alias[less] = more

            # Decrease the probability of the larger one by the appropriate amount.
            weights[more] = weights[more] + weights[less] - avg

            # If the new probability is less than the average, add it into the small list;
            # otherwise add it to the large list.
            if weights[more] >= avg:
                large.push_front(more)
            else:
                small.push_front(more)

        # At this point, everything is in one list, which means that the remaining probabilities
        # should all be 1 / n.  Based on this, set them appropriately. Due to numerical issues, we
        # can't be sure which stack will hold the entries, so we empty both.
        while not small.empty():
            less = small.back(); small.pop_back()
            proba[less] = 1.
        while not large.empty():
            more = large.back(); large.pop_back()
            proba[more] = 1.

        self.n = n
        self.alias = alias
        self.proba = proba

    cdef bint coin_toss(self, float p):
        """Sample a loaded coin toss.

        Parameters:
            p: Heads probability.

        """
        return self.generator() < self.maxi * p

    cdef int fair_die(self, int n):
        """Sample a fair n-sided die.

        Parameters:
            n: The number of faces on the die.

        """
        return self.generator() * n / self.maxi

    cdef int sample_1(self):

        # Generate a fair die roll to determine which column to inspect.
        cdef int col = self.fair_die(self.n)

        # Generate a biased coin toss to determine which option to pick.
        cdef bint heads = self.coin_toss(self.proba[col])

        # Based on the outcome, return either the column or its alias.
        if heads:
            return col
        return self.alias[col]

    cdef np.int_t [:] sample_k(self, int k):
        cdef np.int_t [:] samples = np.zeros(k, dtype=int)
        cdef int i
        for i in range(k):
            samples[i] = self.sample_1()
        return samples

    def sample(self, k=1):
        """Sample a random integer.

        Parameters:
            k: The number of integers to sample. If `k = 1`, then a single int is returned. In any
                other case, a numpy array is returned.

        """

        if k == 1:
            return self.sample_1()
        return np.asarray(self.sample_k(k))
