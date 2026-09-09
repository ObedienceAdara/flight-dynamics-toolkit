# Notice

This project is a restructured derivative of `FLIGHTv2.m` and its supporting functions, from the online supplement to:

> Stengel, R. F., *Flight Dynamics*, 2nd ed. Princeton University Press.
> https://stengel.mycpanel.princeton.edu/FDcodeB.html

The original code is:

> Copyright 2023-2024 by Robert F. Stengel. All rights reserved.

The equations of motion, aerodynamic model structure, trim/linearization approach, and the business-jet aircraft data tables are Stengel's work, used here for educational purposes with attribution. This repository does not claim any of that as original work; the contribution here is entirely the software architecture around it -- removing global state, adding tests, config-driven scenarios, and MATLAB/Octave portability -- described in `docs/ARCHITECTURE.md`.

No warranty, express or implied, is made regarding the accuracy or correctness of this code, consistent with the original's own disclaimer.
