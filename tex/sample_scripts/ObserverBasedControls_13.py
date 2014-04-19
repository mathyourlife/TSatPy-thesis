
import numpy as np
from TSatPy.Actuator import Actuator

print('Actuator Usage')

configs = [{'type': 'fan',
 'args': {'name': 'CW', 'center': (2, -2, 0),'direction': (-1, -1, 0)}
},{'type': 'fan',
 'args': {'name': 'CCW1', 'center': (-2, 2, 0),'direction': (-1, -1, 0)}
},{'type': 'fan',
 'args': {'name': 'CCW2', 'center': (-2, 2, 0),'direction': (-1, -1, 0)}
},{'type': 'fan',
 'args': {'name': 'NY', 'center': (5, 0, 0),'direction': (0, 0, -1)}
},{'type': 'fan',
 'args': {'name': 'NX', 'center': (0, 5, 0),'direction': (0, 0, -1)}}]

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
