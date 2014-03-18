Items since last meeting:

* Abstract draft completed
* Clearer list of work remaining and thesis outline

***

* Find a programming / robotics conference
    * Space flight conference?
    * PyCon

* Fix mcode issue later - write now

* Get membership for
    * ASME (dynamics systems + control)
    * AIAA (GNC)
    * IEEE(Control Systems Society)

* reference tablesat2 as future platforms

***

Writing TODO:

* Abstract (draft done)
* Introduction
    * MMS Mission (draft done)
    * Previous Work / TableSat outreach purpose
    * Thesis focus
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
