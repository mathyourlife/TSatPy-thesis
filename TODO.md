**Items since last meeting**

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

**Questions**

* how video in thesis
* time nomenclature
* timing for review and hand off to committee
* Jeff Kite - footnote reference
* Name of original CS student
* Calendar okay?

Notes:

* Focus on ability to apply on future
* Test print to make sure
* May-Win reach out to Fussell then I reach out
* Where printing?
* After, Mike Chris Tom how to use TSatPy

***

**Chapter Status**

* Abstract **(draft completed)**
* Intro Chapter **(draft completed)**
* TableSat 1A **(draft completed)**
* Satellite Attitude Modeling **(draft complete)**
* Observer Based Controls
* Standard Control Theory Tools
* Software Development fur Experimental Integration
* TSatPy
* Conclusions
* Future Work

***

**Coding Status**

* Estimators
    * PID (done)
    * EKF
    * SMO
    * Estimator Master
* Controllers
    * PID
    * SMC
    * Controller Master
* Actuators
    * Feed moments back to estimators
* Coordinator
    * timer integration
    * functional testing

***

TODO

* Video in thesis?
    * [Unforced Plant](https://vimeo.com/68018120)
    * [Forced Plant](https://vimeo.com/42960673)
* Remind Fussell of committee
* Check in with Hatcher about code review
* Find a programming / robotics conference
    * Space flight conference?
    * PyCon
* Get membership for
    * ASME (dynamics systems + control)
    * AIAA (GNC)
    * IEEE(Control Systems Society)
* reference tablesat2 as future platforms
* Matlab code line length
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

Notes

Commencement info

* [http://www.unh.edu/universityevents/commencement/](http://www.unh.edu/universityevents/commencement/)
