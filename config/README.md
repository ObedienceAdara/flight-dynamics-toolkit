# Scenario file schema

A scenario file is a JSON document describing a flight condition, an aircraft,
and what analysis to run. It replaces the "2. USER INPUTS" section that used
to be hardcoded directly inside `FLIGHTv2.m`. See
`businessjet_mach_trim.json` for a complete example (Stengel's own
documented example condition: 3,050 m altitude, Mach 0.3).

All angles are specified in **degrees** for readability; `loadScenario.m`
converts everything to radians internally. The one exception is
`trim.initialGuess`, noted below.

## Top-level fields

| Field | Required | Description |
|---|---|---|
| `aircraft.builder` | yes | Name of an aircraft-builder function on the path, e.g. `"buildBusinessJetMach"` or `"buildBusinessJetAlpha"`. Must return an `Aircraft` object. |
| `rotationMode` | yes | `"Euler"` or `"Quaternion"` -- which equations of motion to integrate. |
| `flightCondition.altitudeMeters` | yes | Trim altitude, meters. |
| `flightCondition.mach` | yes | Trim Mach number. |
| `analysis.trim` | no (default `true`) | Whether to solve for steady, level-flight trim. |
| `analysis.linearize` | no (default `false`) | Whether to compute the LTI (F, G, L) model and modal analysis at the trim point. Requires `analysis.trim`. |
| `analysis.simulate` | no (default `true`) | Whether to integrate the nonlinear equations of motion. |
| `time.initial`, `time.final` | no (default `0`, `30`) | Simulation time span, seconds. |
| `initialConditions.*` | no (all default `0`) | Angle of attack, sideslip, body rates, roll/yaw angle, and north/east position *before* trim overrides throttle/stabilator/pitch. Pitch angle defaults to angle of attack, matching the original. |
| `trim.initialGuess` | no (default `[-0.1, 0.4, 0.01]`) | Starting point for `fminsearch`: `[stabilator, throttle, pitch]`. **Not in degrees** -- stabilator and pitch are radians, throttle is a 0-1 fraction, matching Stengel's own `InitParam`. |
| `testInputs.*` | no (all default `0`) | A one-time control perturbation applied at the start of the simulated trajectory (e.g. an elevator doublet). |
| `statePerturbation.*` | no (all default `0`) | A one-time state perturbation applied to the trimmed state before simulating. |
| `controlHistory.enabled` | no (default `false`) | Whether the piecewise-linear control-perturbation schedule below is active during simulation. |
| `controlHistory.timesSeconds` | no | Sample times for the schedule. |
| `controlHistory.deltas` | no | One object per sample time, same fields as `testInputs`. |

## Known limitations

- There is currently no field for a nonzero *baseline* control vector
  (elevator/aileron/rudder/flap trim tabs held at some fixed nonzero value
  independent of the trim solver). `buildInitialState.m` always starts from
  an all-zero control vector, matching every scenario Stengel shipped. If you
  need this, it's a natural extension: add a `baselineControls` block to the
  schema and thread it through `buildInitialState.m` the same way
  `initialConditions` is handled.
- Only one wind/turbulence model exists (`WindField.m`, currently all zero).
  There's no scenario field for it yet because there's nothing to configure --
  see the "Simulation fidelity" track in the project roadmap for adding a
  real gust model.
