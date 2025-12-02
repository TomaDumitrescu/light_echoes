# Enemy System

This system implements first of all a bat-like enemy using a component-based state approach.

## Structure

- **Enemy**: Base enemy class, inherits from `CharacterBody2D`.
- **Bat**: Concrete enemy, initializes Idle, Chase, and Flee states.
- **EnemyState**: Base class for enemy states with methods:
  - `enter(prev_state)`: Called when changing states
  - `update(delta)`: Update per frame
  - `exit(next_state)`: Called when leaving the state
- **BatIdleState / BatChaseState / BatFleeState**: Concrete states of the Bat AI
- **EnemyComponent**: Base class for components (e.g., sensors)
- **LightAvoidance**: Enemy flees sideways when player beam is active
- **SoundSensor**: Enemy chases player when player is close in particle mode

## How it works

1. **Components check state changes** via `get_intended_state()`.
2. **Enemy** changes state depending on the components.
3. **State** controls movement by setting `velocity`.

=> allows for component compositions like LEGO e.g. SoundSensor and LightAvoidance for Bat, LightAvoidance for Sceletons,

!NOTE: currently state change not properly implemented...needs behaviour in specific EnemyStates not Component (just temp)

TODO:

- change NOTE
- add more Components
- add more Enemy Types
- add graphics
