# Changelog

## [1.0.0] - Software engineering foundations

Initial restructuring of Stengel's `FLIGHTv2.m` toolkit. See
`docs/ARCHITECTURE.md` for full detail and verification methodology.

### Added
- `Aircraft` class: consolidates `BusinJetA.m`/`BusinJetM.m` (data) and
  `AlphaModel.m`/`MachModel.m` (coefficient lookup); loads data once
  instead of re-reading a `.mat` file on every integrator step.
- `ControlHistory` class: replaces the `CONHIS`/`tuHis`/`deluHis`/`RUNNING`
  globals.
- `TrimSolver` handle class: replaces `TrimCostv2.m`'s global
  `u`/`x`/`V`/`TrimHist` pattern.
- `FlightSimulation` orchestrator class: ties trim, linearization, and
  simulation together without global state.
- `eomEuler.m`, `eomQuaternion.m`: functional equations of motion, taking
  aircraft/control-history/control/running-state as explicit parameters.
- `linearize.m`, `natFreq.m`: linearization and modal analysis, with the
  undocumented `esort` dependency removed.
- `euler2quat.m`, `quat2euler.m`, `computeFlightQuantities.m`: extracted
  and named, previously inline in `FLIGHTv2.m`.
- JSON scenario configuration (`config/loadScenario.m` +
  `config/businessjet_mach_trim.json`): flight conditions are now data,
  not source code.
- `matlab.unittest` test suite (`tests/`): kinematics, atmosphere,
  aircraft, control history, equations of motion, trim, linearization,
  full-simulation, scenario loading, and derived quantities.
- `arguments`-block input validation throughout (kept portable to GNU
  Octave -- see README "Portability").

### Changed
- `WindFieldv2.m` renamed to `WindField.m` to match its internal function
  name (required for MATLAB to resolve calls to it by filename).
- `FLIGHTv2.m`'s ~600-line monolithic script split into
  `scripts/run_flight.m` (thin entry point), `scripts/plotFlightResults.m`
  (plotting, previously inseparable from the physics), and the classes
  above.

### Fixed
- `Atmosphere.m` now raises a clear, named error
  (`Atmosphere:AltitudeOutOfRange`) outside its tabulated range, instead of
  the original's unassigned-output crash.

### Known issues carried over from the original (not fixed, by design)
- `AlphaModel`'s rolling-moment asymmetric-spoiler term reads the wrong
  table (`CYdASTable` instead of `CldASTable`).
- `EoMQv2`'s wind-field call uses a different height argument than
  `EoMv2`'s (currently inert; see `docs/ARCHITECTURE.md`).
- The post-simulation normal-load-factor calculation has an off-by-one
  quirk at its first/last samples.

See `docs/ARCHITECTURE.md`, "Three known behavioral quirks preserved from
 the original," for why these were kept rather than silently fixed.
