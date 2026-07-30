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

---

