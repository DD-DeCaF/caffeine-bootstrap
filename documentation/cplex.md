# CPLEX Solver

Caffeine makes heavy use of the CPLEX optimizer. Without it, all mixed-integer
problems may run very slow. This mostly affects the design pipeline but also
fluxomics data.

We cannot bundle the CPLEX package, so you need to manually provide the solver
which we will integrate during installation. Please, place your cplex file in:

```
modeling-base/cplex_128.tar.gz
```

If you are unsure about the format of that file, [please get in
touch](mailto:niso@dtu.dk?subject=Caffeine CPLEX Archive Format).
Learn more at https://www.ibm.com/dk-en/analytics/cplex-optimizer.
