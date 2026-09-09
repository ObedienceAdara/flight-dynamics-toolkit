# Architecture notes

## Mapping from the original files

| Original | Replaced by | Notes |
|---|---|---|
| `Atmos.m` | `src/Atmosphere.m` | Renamed, added validation and an explicit out-of-range error |
| `DCM.m` | `src/DCM.m` | Added validation |
| `RMQ.m` | `src/RMQ.m` | Added validation |
| `WindFieldv2.m` | `src/WindField.m` | Renamed to match its internal function name (required for MATLAB to resolve calls to it) |
| `event.m` | `src/event.m` | Added validation |
| `BusinJetA.m` + `AlphaModel.m` | `data/buildBusinessJetAlpha.m` + `Aircraft` class | Data and coefficient lookup merged into one object |
| `BusinJetM.m` + `MachModel.m` | `data/buildBusinessJetMach.m` + `Aircraft` class | Same |
| `EoMv2.m` | `src/eomEuler.m` | Globals replaced by explicit `aircraft`/`controlHistory`/`uNominal`/`isRunning` parameters |
| `EoMQv2.m` | `src/eomQuaternion.m` | Same |
| `LinModelv2.m` | `src/linearize.m` | Global `u` removed; `u` now travels inside the augmented state vector, as it already did |
| `TrimCostv2.m` | `src/TrimSolver.m` | Global `u`/`x`/`V`/`TrimHist` replaced by a `handle` class so `fminsearch` can call a bound method that accumulates history as a normal property |
| `NatFreq.m` | `src/natFreq.m` | `esort` dependency removed; unused `Sys` parameter dropped; now returns a struct array instead of a dummy placeholder |
| (inline in `FLIGHTv2.m`, Section 6B) | `src/euler2quat.m`, `src/quat2euler.m` | Given names, tests, and reuse |
| (inline in `FLIGHTv2.m`, Section 7) | `src/computeFlightQuantities.m` | Given a name, tests, and reuse; separated from plotting |
| `FLIGHTv2.m` (everything) | `src/FlightSimulation.m`, `scripts/run_flight.m`, `scripts/plotFlightResults.m`, `config/loadScenario.m` | Split into: orchestration class, thin entry-point script, plotting, and configuration |

## Why a `handle` class for `TrimSolver`

`fminsearch` calls its cost function repeatedly with only the current parameter vector; the original captured per-iteration history by mutating a `global TrimHist` inside `TrimCostv2.m`. A `handle` class gives the same capability without the global: `fminsearch(@obj.cost, ...)` binds `obj` by reference, so `obj.cost` can append to `obj.History` on every call, and the caller can read `obj.History` back afterward. This is the standard MATLAB pattern for "optimizer needs to remember state across calls, without a global."

## Why `Atmosphere.m` now throws on out-of-range altitude

The original silently produced a MATLAB "output argument not assigned" error if called above 51,000 m or below -1,000 m, because the `for`/`if` loop that assigns `airDens`/`airPres` would never trigger for such an input. `Atmosphere.m` checks the range explicitly up front and raises a named, descriptive error (`Atmosphere:AltitudeOutOfRange`) instead. This is strictly additive: every input that worked before still works identically; inputs that used to crash with a cryptic message now crash with a clear one.

## Why `esort` was replaced in `natFreq.m`

`esort` is an undocumented, legacy Control System Toolbox function. It is not part of GNU Octave (`exist('esort')` returns `0`), and its presence in any given licensed MATLAB installation is not guaranteed either -- it does not appear in current MATLAB documentation. `esort`'s actual behavior (sorting continuous-time eigenvalues by decreasing real part) was reverse-engineered from a compatible shim, used to run the original `NatFreq.m` for comparison, and confirmed to match `natFreq.m`'s explicit `sort(real(eigenvalues), 'descend')` bit-for-bit on a representative test matrix (mixed real and complex-conjugate eigenvalues).

## Three known behavioral quirks preserved from the original

These were found during the line-by-line port and deliberately **not** silently corrected, since a "behavior-preserving refactor" that quietly changes numeric output on some inputs isn't actually behavior-preserving. Each is documented at its point of occurrence in the source and repeated here:

1. **`AlphaModel.m`'s rolling-moment asymmetric-spoiler term.** The original reads `CldAS = interp1(AlphaTable, CYdASTable, alphadeg)` -- using the side-force asymmetric-spoiler table where a rolling-moment table (`CldASTable`) was almost certainly intended. Preserved verbatim in `Aircraft.aeroCoefficientsAlpha`, with the discrepancy called out inline.
2. **`EoMQv2.m`'s wind-field height argument.** `eomEuler.m`/`EoMv2.m` call `WindField(-x(6), ...)` (altitude); `eomQuaternion.m`/`EoMQv2.m` call `WindField(x(3), ...)` (body-axis normal velocity) -- an apparent copy/paste inconsistency. Currently inert, since the default `WindField.m` tables are all zero regardless of input; would matter the moment a real altitude-dependent wind or turbulence profile is added.
3. **`computeFlightQuantities.m`'s normal-load-factor endpoints.** The original's central-difference loop for `nz` runs `for i = 2:tLength-1` and then reuses the loop variable's leftover value (`i = tLength-1`) for both `nz(1)` and `nz(tLength)`, rather than resetting `i` to `1` and `tLength` respectively. Separately, the very last sample divides by `(tf - t(tLength-1))` -- the scenario's configured final time -- rather than `(t(tLength) - t(tLength-1))`, so if the ground-impact event terminates a run early, this endpoint uses the wrong time delta. Both are preserved exactly, with `tf` threaded through as an explicit parameter specifically so this quirk could be reproduced rather than silently using `t(end)` instead.

None of these affect the verification results below, since the test conditions used don't exercise the affected code paths' divergent branches (no nonzero wind profile; no early ground-impact termination).

## Dead code removed

Two small pieces of code from `EoMv2.m`/`EoMQv2.m` were dropped because they are provably side-effect-free -- verified by confirming `xdot` is identical with and without them:

- An internal call to `event(t, x)` whose outputs (`value`, `isterminal`, `direction`) were never used. Termination is already handled by `odeset`'s `'Events'` option, which calls `event.m` directly.
- Several intermediate quantities (`Mach`, `alpha`, `beta`, `qbar`, `nz`) that were computed inside the original equations-of-motion functions but never fed back into `xdot` -- they look like leftover debugging variables.

## Verification methodology

Given no way to run real MATLAB in the environment this refactor was built in, GNU Octave 8.4 was used as the execution engine for every verification step below (Octave is not just a testing convenience here -- see the "Portability" section of the main README for why targeting it is also a real design goal). For each component, the original global-variable-based code and the new class/function-based code were run **in separate Octave processes** (to avoid any cross-contamination through leftover global state), on identical inputs, with results saved to `.mat` files and diffed numerically:

| Component | Test | Result |
|---|---|---|
| `Atmosphere`, `DCM`, `RMQ`, `WindField`, `event` | Several representative inputs each | 0 abs diff |
| `Aircraft` (alpha + Mach coefficient lookup) | 3 states x 2 models | 0 abs diff |
| `eomEuler`/`eomQuaternion` | 3 states x 4 (CONHIS, RUNNING) combinations | 0 abs diff |
| `linearize` | 3 augmented states | 0 abs diff |
| `natFreq` | 1 mixed real/complex test matrix (via an `esort`-compatible shim to run the original) | 0 abs diff |
| `TrimSolver` (pointwise cost) | 3 trim-parameter vectors | 0 abs diff |
| `TrimSolver` (full `fminsearch` convergence) | Documented 3,050 m / Mach 0.3 condition | 0 abs diff (`OptParam`, cost, control vector, state vector) |
| `computeFlightQuantities` | Full 1,601-step trajectory | 0 abs diff, all 8 derived quantities |
| Full pipeline (trim -> perturb -> `ode45`, 30 s) | Euler mode | 0 abs diff over all 1,601 steps |
| Full pipeline (short run) | Quaternion mode | Consistent step count; pointwise EoM already verified above |

"0 abs diff" means `max(abs(old - new)) == 0` in IEEE double precision -- not "close," but bit-identical.
