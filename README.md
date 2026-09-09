# Flight Dynamics Toolkit

A restructured, tested, config-driven version of Robert F. Stengel's `FLIGHTv2.m` six-degree-of-freedom flight simulation (from the supplement to *Flight Dynamics*, 2nd ed.). The physics is unchanged and numerically verified against the original; what's different is how the code is organized.

## What changed, and why

The original toolkit worked, but it was hard to build on:

- **20+ `global` variables** threaded aircraft data, control state, and simulation flags through nine separate files. Running two aircraft in the same session, or writing a unit test for one function in isolation, meant fighting the globals.
- **Flight conditions were hardcoded.** Trying a new altitude/Mach/aircraft meant editing `FLIGHTv2.m` directly.
- **`AlphaModel.m`/`MachModel.m` re-read their aircraft data from disk on every single integrator step** -- a real performance cost, not just a style issue.
- There were **no tests**, and one dependency (`esort`, used by `NatFreq.m`) is an undocumented legacy function that isn't part of GNU Octave and isn't guaranteed to exist even in licensed MATLAB.

This restructuring addresses all four, while changing the underlying numerics as little as possible -- see "Verification" below for exactly how that was checked, and `docs/ARCHITECTURE.md` for a few small, deliberate behavior quirks in the original that were preserved rather than silently "fixed."

## Layout

```
src/       Aircraft, ControlHistory, TrimSolver, FlightSimulation classes;
           equations of motion; kinematics; atmosphere; helpers
data/      Aircraft data builders (buildBusinessJetAlpha, buildBusinessJetMach)
config/    JSON scenario files + loadScenario.m + schema docs
scripts/   run_flight.m (entry point), plotFlightResults.m
tests/     matlab.unittest test suite
docs/      Architecture notes, decision log
```

## Quick start

```matlab
addpath('src', 'data', 'config', 'scripts');
results = run_flight();            % runs config/businessjet_mach_trim.json
plotFlightResults(results);        % reproduces the original's 8 figures
```

To run a different flight condition, copy `config/businessjet_mach_trim.json`, edit it, and pass the path:

```matlab
results = run_flight('config/my_scenario.json');
```

See `config/README.md` for the full scenario schema.

## Running the tests

```matlab
addpath('src', 'data', 'config', 'scripts', 'tests');
results = runAllTests();
```

## Portability: MATLAB and GNU Octave

This toolkit is written to run in both licensed MATLAB and free GNU Octave (checked against Octave 8.4), since that's a realistic choice for students. Concretely, that meant:

- Class properties don't use MATLAB-only attributes like `SetAccess = immutable` or per-property type/size validation -- Octave's `classdef` hard-errors on both. Immutability is enforced by convention (set once, in the constructor; no setters) instead of by the language.
- `arguments` blocks are used for required-parameter documentation (Octave warns but still runs correctly), but **never** for optional parameters with defaults -- Octave's `arguments` support does not evaluate defaults at all, silently leaving the variable undefined. Optional parameters use plain `nargin` checks instead.
- The `matlab.unittest` framework itself isn't available in Octave, so the test suite is MATLAB-only; correctness was instead independently verified by running old and new code side-by-side in Octave and diffing outputs (see "Verification").
- Cosmetic-only: Octave prints a warning every time it hits an `arguments` block ("function arguments validation blocks are not supported"). This is harmless noise, not an error -- everything still runs and produces correct results, as the verification below confirms. Real MATLAB doesn't print this at all.

## Verification

Every numeric component was checked against the original by running both implementations on identical inputs and diffing the outputs -- not just reading the code and asserting equivalence. Highlights:

- All pure-function layers (`Atmosphere`/`Atmos`, `DCM`, `RMQ`, `WindField`, `event`) matched to **0** absolute difference.
- The `Aircraft` class's aerodynamic coefficient lookups matched `AlphaModel.m`/`MachModel.m` to **0** absolute difference across a spread of test states/controls.
- `eomEuler.m`/`eomQuaternion.m` matched `EoMv2.m`/`EoMQv2.m` to **0** absolute difference across 12 combinations of state, `CONHIS`, and `RUNNING`.
- `TrimSolver` reproduced the original's converged trim point ([-0.048561779, 0.18920754, 0.077368166] at Stengel's documented 3,050 m / Mach 0.3 condition) to **0** absolute difference.
- A **full end-to-end run** -- trim, apply an elevator doublet, integrate 30 seconds with `ode45` -- matched the original's 1,601-step trajectory to **0** absolute difference, in both Euler and quaternion modes.

Full detail, including the three known behavioral quirks in the original that were found and preserved (not silently fixed), is in `docs/ARCHITECTURE.md`.

## Attribution

The aerodynamic model, equations of motion, and simulation architecture are Robert F. Stengel's. See `NOTICE.md`.
