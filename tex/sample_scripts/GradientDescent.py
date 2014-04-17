"""
Gradient Descent Parameter Tuning

Provide a function to find the best input parameters.  "Best" is quantified
through a function provided by the user to quantify the results of the test.


Example:
    An experiment creates data based on the underlying equation of
        (x-5)^2 + (y+2)^2 + (z-1)^2

    Gradient descent should find the local minimum of (5, -2, 1)

Finds:
    Best performance at
    x:
      val: 4.67357  range: -10,10   std: 0.786667
    y:
      val: -2.37629 range: -10,10   std: 0.606853
    z:
      val: 0.920501 range: -10,10   std: 0.548887
"""

import numpy as np


def run_experiment_with_these(x, y, z):
    """
    Run some experiment and generate performance data.
    """
    norms = []
    for _ in xrange(10):
        n = (np.random.randn()*3 + (x-5))**2 + \
            (np.random.randn()*0.3 + (y+2))**2 + \
            (np.random.randn()*0.1 + (z-1))**2
        norms.append(n)

    return [norms]


def measure_performance(norms):
    """
    Take the performance data from the experiment and calculate a score.
    Lower means better.
    """
    n_array = np.array(norms)
    return n_array.mean()


class GradientDescent(object):
    """
    A Gradient Descent algorithm for tuning the input parameters for
    a function.
    """

    @classmethod
    def _next_test_args(cls, arg_data):
        """
        Determine the next set of arguments to be passed to the test function.
        Testing starts with a wide net across all parameters.  As some better
        performing regions are found the parameters start converging on
        that area.
        """
        kwargs = {}
        for key, lower, upper, mean, std in arg_data:
            val = None
            while val is None or not (lower < val < upper):
                val = np.random.randn() * std + mean
            kwargs[key] = val
        return kwargs

    @classmethod
    def descend(cls, domains, run_test, calc_cost, N):
        """
        Tune in to the "best" parameters as measured by the calc_cost func.
        """
        results = []
        arg_data = []

        keys = []
        for domain in domains:
            keys.append(domain[0])
            domain.append((domain[1] + domain[2]) / 2.0)
            domain.append((domain[2] - domain[1]) / 4.0)
            arg_data.append(domain)

        thresh = N * 0.2
        if thresh < 10:
            thresh = N - 1

        for _ in range(N):
            kwargs = cls._next_test_args(arg_data)
            cost = calc_cost(*run_test(**kwargs))

            args = []
            for key in keys:
                args.append(kwargs[key])
            args.append(cost)
            print args
            results.append(args)

            if len(results) > thresh:
                rdata = np.array(results)
                rdata = rdata[rdata[:, -1].argsort()]
                for idx, mean in enumerate(rdata[0:thresh/2, :-1].mean(axis=0)):
                    arg_data[idx][3] = mean
                for idx, std in enumerate(rdata[0:thresh/2, :-1].std(axis=0)):
                    arg_data[idx][4] = std

        return cls.finalize(arg_data)

    @classmethod
    def finalize(cls, arg_data):
        """
        Print out of test results and what values seemed to perform the best.
        """

        kwargs = {}
        print("Best performance at")
        for key, lower, upper, val, std in arg_data:
            kwargs[key] = val
            print("%s:" % key)
            print("  val: %g\trange: %g,%g\tstd: %g" % (
                val, lower, upper, std))

        return kwargs


def main():
    """
    Run the demo Gradient Descent
    """
    domains = [
        ['x', -10, 10],
        ['y', -10, 10],
        ['z', -10, 10],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 1000,

        # Definition of parameter search domain
        'domains': domains,

        # Function that will run a test
        'run_test': run_experiment_with_these,

        # Function that will take the return of run_test and determine
        # how well the parameters worked.
        'calc_cost': measure_performance,
    }
    print GradientDescent.descend(**kwargs)

    return 0


if __name__ == "__main__":
    exit(main())
