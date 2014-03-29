Items since last meeting:

* Abstract (draft completed)
* Intro Chapter (draft completed)
* TableSat 1A (draft completed)
* Satellite Attitude Modeling (almost draft complete)
* Graduation
    * registered for commencement
    * Hood/cap/gown arrived
* Correspond w/ grad school
    * Loose deadline for defense
    * May 2014 is the end
* mcode formatting fix (now minted)

***

Chapter Status
* Abstract (draft completed)
* Intro Chapter (draft completed)
* TableSat 1A (draft completed)
* Satellite Attitude Modeling (almost draft complete)
* Observer Based Controls
* Standard Control Theory Tools
* Software Development fur Experimental Integration
* TSatPy
* Conclusions
* Future Work

***

* Find a programming / robotics conference
    * Space flight conference?
    * PyCon

* Get membership for
    * ASME (dynamics systems + control)
    * AIAA (GNC)
    * IEEE(Control Systems Society)

* reference tablesat2 as future platforms

* Slerp?

```python
def slerp(t, q0, q1):
    """Spherical linear interpolation between two quaternions.

    The return value is an interpolation between q0 and q1. For t=0.0
    the return value equals q0, for t=1.0 it equals q1.
    q0 and q1 must be unit quaternions.
    """
    global _epsilon

    o = math.acos(q0.dot(q1))
    so = math.sin(o)

    if (abs(so)<=_epsilon):
        return quat(q0)

    a = math.sin(o*(1.0-t)) / so
    b = math.sin(o*t) / so
    return q0*a + q1*b
```

***

Commencement info

* [http://www.unh.edu/universityevents/commencement/](http://www.unh.edu/universityevents/commencement/)

***

Writing TODO:

* Abstract (draft done)
* Introduction (draft done)
    * NASA Magnetospheric MultiScale Mission
    * Research Objective
    * Past Work
    * Analytical and Experimental Test Bed
    * Thesis Contributions
    * Thesis Outline
* Analytical Work
    * State Representation
        * Quaternions
        * System Dynamics
        * Quaternion Decomposition
        * Decouple Body Rate and Nutation Control
    * Control Theory
        * Error Measurement
        * PID Estimation
        * EKF
        * SMO
        * PID Control
        * SMC
    * Simulations
        * Plant System Dynamics
        * 3D Visualizations
        * EKF
    * Experimental Validation
        * Course Sun Sensors
        * Triple Axis Magnetometer
        * Rate Control
        * Nutation Control
* Basic Matlab Attitude Determination and Controls
    * Simulink Based
    * TSat Message Center
* Advanced Matlab Attitude Determination and Controls
    * GUI
    * Object Oriented
* TSatPy - Python Attitude Determination and Controls
    * Architecture
    * Connection Protocol
    * Message Definitions
    * Voltage to Attitude Measurement Conversions
    * Estimators
    * Controllers
    * Actuators
    * Event loops
* Conclusion
* Future Work

***

Python Coding TODO:

* Simulation Clock (done)
* Math (done)
    * Variable step discrete integral (done)
    * Variable step discrete derivative (done)
* State (done)
    * Quaternion (done)
    * Body Rate (done)
    * Quaternion Error (done)
    * Quaternion Dynamics (done)
    * Euler Moment Equations (done)
    * Full State (done)
    * Rigid body plant (done)
* State Operations + - * / (done)
* Sensors
    * Photo Diode Array (done)
    * TAM
* Estimator
    * PID (done)
    * EKF
    * SMO
    * Estimator Master
* Integrate Sensor to Estimator
* Controller
    * PID
    * SMC
    * Controller Master
* Integrate Estimator to Controller
* Actuators
    * Moment Desired to Actual
    * Feedback Actual to estimator/controller
* Comm in/out
    * Complete the loop
