# Assertions


# Understanding `$rose` in SystemVerilog Assertions (SVA)

## What `$rose` Does
- `$rose(expr)` detects a **rising edge** (transition from `0` → `1`) of a Boolean expression or signal.
- It evaluates to **true for one simulation cycle** when the signal changes from `0` to `1`.

Equivalent definition:
```systemverilog
$rose(expr) ≡ expr && !$past(expr)
```

---

## Truth Table

| Previous Value | Current Value | `$rose(expr)` |
|----------------|---------------|----------------|
| 0              | 0             | 0              |
| 0              | 1             | 1 (OK)         |
| 1              | 0             | 0              |
| 1              | 1             | 0              |

---

## How It Works

- $rose(expr) is equivalent to checking:
- where:
  - expr is the current value of the signal.
  - $past(expr) is the value of the signal in the previous cycle.
- So, $rose(expr) is true only if:
  - Current value = 1
  - Previous value = 0

## Example

```systemverilog
property p1;
  @(posedge clk) $rose(req) |-> grant;
endproperty
```

- Meaning: Whenever `req` rises (goes from 0 to 1), then `grant` must be true in the same cycle.
- `$rose(req` acts like a trigger condition.

**In short**: `$rose` is your go-to detector for a rising edge in assertions. It’s especially useful for triggering properties when a control signal (like `req`, `start`, or `enable`) becomes active.


## Clocking in Assertions

In SVA, properties are always evaluated relative to a clocking event.
For example:

```systemverilog
@(posedge clk) expr
```
means: sample `expr` at every rising edge of `clk`.

## `$rose(signal)` vs. `signal` inside `@(posedge clk)`
Let’s compare:

### Case 1: Using signal

```systemverilog
property p1;
  @(posedge clk) signal |-> grant;
endproperty
```

- Here, the property triggers whenever signal is high (1) at the sampling edge.
- It doesn’t care if signal just rose or has been high for multiple cycles.


### Case 2: Using `$rose(signal)`

```systemverilog
property p2;
  @(posedge clk) $rose(signal) |-> grant;
endproperty
```

- Here, the property triggers only when `signal` transitions from 0 → 1 at the sampling edge.
- If `signal` stays high for several cycles, `$rose(signal)` is true only on the first cycle of the transition.

### Insight

- `signal` → checks level (is it high now?).
- `$rose(signal)` → checks edge (did it just rise now?).
This distinction is crucial when modeling handshakes or trigger events:
- Use `signal` if you want to enforce something while the signal is high.
- Use `$rose(signal)` if you want to enforce something only when the signal activates.


### `$rose` with Implication (`|->`)

The operator `|->` means if the antecedent is true, then the consequent must hold.
Example:

```systemverilog
property req_grant;
  @(posedge clk) $rose(req) |-> grant;
endproperty
```

- Interpretation: Whenever req rises, grant must be true in the same cycle.

## `$rose` with Delays (`##N`)

The delay operator `##N` means after N clock cycles.
Example:

```systemverilog
property req_grant_delay;
  @(posedge clk) $rose(req) |-> ##[1:3] grant;
endproperty
```

- Interpretation: Whenever `req` rises, `grant` must be asserted within 1 to 3 cycles.
- `$rose(req)` ensures the property triggers only once per request activation, not every cycle while `req` is high.

- 

## `$rose` vs. Signal Level in Assertions

### Using `signal`
```systemverilog
property p1;
  @(posedge clk) signal |-> grant;
endproperty
```

- Triggers whenever signal is high at the sampling edge.
- Does not distinguish between a new rise and a sustained high.
  
Using $rose(signal)

```systemverilog
property p2;
  @(posedge clk) $rose(signal) |-> grant;
endproperty
```

- Triggers only when signal transitions from 0 → 1.
- Edge-sensitive, avoids retriggering while signal stays high.


## `$rose` with Temporal Operators

### Immediate Grant

```systemverilog
property req_grant;
  @(posedge clk) $rose(req) |-> grant;
endproperty
```

- Whenever req rises, grant must be true in the same cycle.

### Grant Within N Cycles

```systemverilog
property req_grant_delay;
  @(posedge clk) $rose(req) |-> ##[1:3] grant;
endproperty
```

- Whenever req rises, grant must be asserted within 1–3 cycles.


## $rose with Sequence Repetition

### Grant Must Stay High for 3 Cycles

```systemverilog
property req_grant_stable;
  @(posedge clk) $rose(req) |-> grant[*3];
endproperty
```

- Whenever req rises, grant must remain high for 3 consecutive cycles.

### Grant Must Stay High Until Ack

```systemverilog
property req_grant_ack;
  @(posedge clk) $rose(req) |-> grant[*1:$] ##1 ack;
endproperty
```