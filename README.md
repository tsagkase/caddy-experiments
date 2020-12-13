# Caddy usage examples

Experiments with the [Caddy (web server)](https://caddyserver.com)
used as 

   - *reverse proxy* to *multiple* API endpoints, and
   - *laod balancer* between multiple instances of same service

## The setup

Two sites / endpoints 

   - [`site1`](./site1), and
   - [`site2`](./site2)

are spawned to test the scenarios.

These sites may be spawned on their own using:

```sh
    make run_site1
    make run_site2
```

As soon as they are up and running you may access them via HTTP GET requests on

   - [site1](http://localhost:8181)
   - [site2](http://localhost:8282)

To shut them down just run

```sh
    make stop_site1
    make stop_site2
```

## *Reverse proxy* to multiple API endpoints

This scenario spawns a reverse proxy to expose the two sites to the world.
The reverse proxy may be run by

```sh
    make run_rp_proxy
```

It will spawn the two sites / services if not spawned already.

Access to the reverse proxy is via HTTP**S** *only*.
The two sites are exposed as:

   - [api1](https://localhost:8079/api1/resource), and
   - [api2](https://localhost:8079/api2/resource)

You may shutdown the reverse proxy along with the sites it proxies by

```sh
    make stop_rp_proxy
```


## *Load balancer* to multiple instances

This scenario spawns a reverse proxy that load balances between the two sites requests it receives from the world.
The load balancer may be run by

```sh
    make run_lb_proxy
```

It will spawn the two sites / services if not spawned already.

Access to the load balancer is via HTTP**S** *only*.
The two sites are exposed [here](https://localhost:8078).
Requests there will arbitrarily expose one or the other service.
Different load balancing policies are advertised as supported in the Caddy documentation.

You may shutdown the load balancer along with the sites it proxies by

```sh
    make stop_lb_proxy
```

