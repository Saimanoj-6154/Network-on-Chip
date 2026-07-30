# Network-on-Chip

A synthesizable on-chip interconnect fabric — parametrized mesh/torus topology with wormhole-switched routers, virtual channels, and credit-based flow control — built to replace point-to-point/bus interconnects as the on-chip communication backbone for a multi-core or multi-IP SoC.

## Overview

- **Topology**: parametrized 2D mesh (extensible to torus), configurable
  rows × columns, one router per node with local IP/core port
- **Router microarchitecture**: 5-stage pipeline — Buffer Write (BW),
  Route Computation (RC), VC Allocation (VA), Switch Allocation (SA),
  Switch Traversal (ST) — with lookahead routing to shave a pipeline
  stage where possible
- **Switching**: wormhole switching with multiple virtual channels (VCs)
  per physical link, avoiding head-of-line blocking across independent
  traffic flows
- **Flow control**: credit-based backpressure between routers, no
  packet drop under congestion
- **Routing algorithm**: deterministic XY routing baseline (deadlock-
  free by construction), with an adaptive/odd-even routing variant as
  an extension
- **QoS / arbitration**: round-robin VC and switch allocation, with an
  optional priority class for latency-sensitive traffic
- **Network interface**: packetization/de-packetization adapters so
  cores/IPs see a simple request/response interface, not raw flits
- **Verification**: functional coverage on routing paths and VC/buffer
  occupancy, deadlock/livelock checks via SVA, and traffic-pattern-
  based throughput/latency characterization



  ## Architecture Overview

```
                  Node(0,0)      Node(1,0)      Node(2,0)
                 ┌────────┐     ┌────────┐     ┌────────┐
                 │ Router  │────▶│ Router  │────▶│ Router  │
                 │  + IP   │◀────│  + IP   │◀────│  + IP   │
                 └───┬────┘     └───┬────┘     └───┬────┘
                     │                  │                  │
                  Node(0,1)      Node(1,1)      Node(2,1)
                 ┌───▼────┐     ┌───▼────┐     ┌───▼────┐
                 │ Router  │────▶│ Router  │────▶│ Router  │
                 │  + IP   │◀────│  + IP   │◀────│  + IP   │
                 └────────┘     └────────┘     └────────┘

   Per-router pipeline:
   ┌────┐   ┌────┐   ┌────┐   ┌────┐   ┌────┐
   │ BW │──▶│ RC │──▶│ VA │──▶│ SA │──▶│ ST │──▶ output port
   └────┘   └────┘   └────┘   └────┘   └────┘
   (buffer   (route    (VC       (switch   (crossbar
    write)   compute)  alloc)    alloc)    traversal)
```


## Repository Structure

```
network-on-chip/
├── README.md
├── LICENSE
├── .gitignore
├── Makefile                          # top-level: make sim / make regress / make characterize
├── docs/
│   ├── router_microarchitecture.md   # pipeline stages, VC allocation, switch allocation
│   ├── routing_algorithm.md          # XY routing, deadlock-freedom argument, adaptive variant
│   ├── flow_control.md               # credit-based backpressure, VC/buffer sizing
│   └── verification_plan.md          # test plan, coverage model, traffic patterns used
│
├── rtl/
│   ├── router/
│   │   ├── router_top.sv
│   │   ├── input_buffer.sv           # per-VC buffering
│   │   ├── route_compute.sv          # XY / adaptive routing logic
│   │   ├── vc_allocator.sv
│   │   ├── switch_allocator.sv
│   │   ├── crossbar.sv
│   │   └── credit_counter.sv         # credit-based flow control per output VC
│   ├── network/
│   │   ├── mesh_top.sv               # instantiates R x C routers, wires mesh links
│   │   └── link.sv                   # inter-router physical link (flit + credit signals)
│   ├── ni/
│   │   ├── network_interface.sv      # packetize/de-packetize adapter
│   │   └── flit_defs.sv
│   └── common/
│       └── pkg_noc_params.sv         # mesh dims, VC count, buffer depth, flit width
│
├── verif/
│   ├── tb/
│   │   ├── router_tb.sv              # single-router unit test
│   │   ├── mesh_tb.sv                # full-network sim with traffic generators
│   │   └── deadlock_check_tb.sv
│   ├── traffic_gen/
│   │   ├── uniform_random.py         # uniform random traffic pattern generator
│   │   ├── transpose_pattern.py
│   │   ├── hotspot_pattern.py        # many-to-one congestion pattern
│   │   └── bit_complement.py
│   ├── sva/
│   │   ├── deadlock_freedom_assertions.sv  # no cyclic buffer dependency (XY routing invariant)
│   │   ├── credit_conservation_assertions.sv
│   │   └── vc_allocation_assertions.sv
│   └── ref_model/
│       └── flit_level_sim.py         # Python cycle-approximate model for latency/throughput cross-check
│
├── sim/
│   └── verilator/
│       ├── Makefile
│       └── sim_main.cpp
│
├── characterization/
│   ├── run_sweep.py                  # sweeps injection rate, collects latency/throughput
│   ├── latency_vs_load_plot.py
│   └── saturation_throughput.py      # finds network saturation point per traffic pattern
│
├── scripts/
│   └── run_regression.py
│
└── .github/
    └── workflows/
        └── ci.yml                    # lint + router/small-mesh smoke tests on push
```

---


### Tools

- Verilator ≥ 5.0
- Python 3.10+ with NumPy/Matplotlib (traffic generation, characterization plots)
- GTKWave for waveform debug


---

