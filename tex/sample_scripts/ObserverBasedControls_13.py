
import numpy as np
from TSatPy.Actuator import Actuator

print('Actuator Usage')

configs = [{'type': 'fan', 'args': {'name': 'CW', 'center': (2, -2, 0),
  'direction': (-1, -1, 0), 'F': 10}
},{'type': 'fan', 'args': {'name': 'CCW1', 'center': (-2, 2, 0),
  'direction': (-1, -1, 0), 'F': 10}
},{'type': 'fan', 'args': {'name': 'CCW2', 'center': (-2, 2, 0),
  'direction': (-1, -1, 0), 'F': 10}
},{'type': 'fan', 'args': {'name': 'NY', 'center': (5, 0, 0),
  'direction': (0, 0, -1), 'F': 10}
},{'type': 'fan', 'args': {'name': 'NX', 'center': (0, 5, 0),
  'direction': (0, 0, -1), 'F': 10}}]


def set_level(act, power_level):
    print 'Setting power level=%g for: %s' % (power_level, act)


def setup_actuators(configs):
    act = Actuator()
    for config in configs:
        act.add(config['type'], set_level, config['args'])
    return act


def main():
    act = setup_actuators(configs)
    print act
    M = np.mat([3, 11, 4]).T
    print("\nRequest moment: %s" % (M.T))
    print
    print("\nApplied moment: %s" % (act.request_moment(M).T))
    return 0


if __name__ == '__main__':
    main()


# Prints Out
# Actuator Usage
# Actuator
#  <Fan CW moment=(0, -0, -4)>
#  <Fan CCW1 moment=(0, 0, 4)>
#  <Fan CCW2 moment=(0, 0, 4)>
#  <Fan NY moment=(-0, 5, 0)>
#  <Fan NX moment=(-5, 0, 0)>

# Request moment: [[ 3 11  4]]

# Setting power level=1 for: <Fan NY moment=(-0, 5, 0)>
# Setting power level=0.5 for: <Fan CCW1 moment=(0, 0, 4)>
# Setting power level=0.5 for: <Fan CCW2 moment=(0, 0, 4)>

# Applied moment: [[ 0.  5.  4.]]
