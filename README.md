
```
 mmmmm  mmmmm   mmmm  m    m  mmmm m     m
 #   "#   #    #"   " #  m"  m"  "m#  #  #
 #mmmm"   #    "#mmm  #m#    #    #" #"# #
 #   "m   #        "# #  #m  #    # ## ##"
 #    " mm#mm  "mmm#" #   "m  #mm#  #   #

                 (__)
                 (oo)
           /------\/
          / |    ||
         *  /\---/\
            ~~   ~~
..."Have you mooed today?"...
```

RISC-V Processor made in livestream at twitch: https://www.youtube.com/playlist?list=PLEP_M2UAh9q52a-w3ZUEChEoG_ROeMa88 (PT-BR)


# Riskow

Riskow is a RISC-V processor implemented in Verilog. It was developed in
livestreams, with the recordings available in
[this playlist](https://www.youtube.com/playlist?list=PLEP_M2UAh9q52a-w3ZUEChEoG_ROeMa88) (Portuguese).

The repository includes:

- CPU and peripheral RTL modules;
- Verilog simulation testbenches and RISC-V instruction test programs;
- firmware sources and memory images;
- ECP5 FPGA constraints and synthesis/place-and-route targets.

## Testing

Run the simulation suite with:

```sh
make test
```

The test-data generation runs on the host and expects GNU Make, `hexdump`, and
`riscv64-linux-gnu-gcc-10`, `riscv64-linux-gnu-ld`, and
`riscv64-linux-gnu-objcopy`. Simulations run in the `racerxdl/icarus` Docker
image, so a running Docker daemon is also required.

## License

Riskow is licensed under the [Apache License 2.0](LICENSE).