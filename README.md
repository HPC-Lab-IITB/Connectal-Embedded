# Embedded-processing-using-the-Connectal-framework

Connectal is the framework which enables the development of hardware accelerators for software implementations from abstract Interface Design Language (IDL) specifications.

Connectal supports asynchronous remote method invocation from software to software, hardware to software, software to hardware and hardware to hardware.

This uses shared memory between software and hardware components which is an advantage for high-bandwidth communication. Reduces the repetitive interfacing of processors from project tasks.

Critical components are implemented in hardware and non-critical components are implemented in software.

Connectal  is  a  software-driven  hardware  framework.   Connectal  is  used  toconnect hardware and software.

More details about the connectal is available [here](https://www.connectal.org/)

## Getting Started
Detailed procedure to install bluesim is avaliable at
```
    https://github.com/B-Lang-org/bsc
```

Detailed procedure to install connectal is avaliable at
```
    https://github.com/cambridgehackers/connectal
```

Try out examples in the connectal folder. Commands used to simulation an example are
```
    cd examples/examplename
    make build.<target>
    make run.<target>
```
where <target> platform can be bluesim, zedboard, zybo, zc720, zc706, kc705, vc707, vc709, nfsume.

  
### About the source codes (in BSV and C++)

For  hardware  components  of  connectal,  we  use  Bluespec  System  Verilog(BSV) as it supports a higher level of abstraction.

For software components, C/C++ is used to implement it.

By interfacing software and hardware, we can accelerate the system. One of the example implemented is finding inverse of a matrix using GF(2) arithmetic. More details on GF(2) arithmetic is avaliable .[here].(https://en.wikipedia.org/wiki/GF(2))

Send input from C++ to Bluesim and wait for the result to arrive, sem_wait and sem_post are used to lock and release the semaphore. More details on this are avaliable .[here].(https://www.geeksforgeeks.org/use-posix-semaphores-c/)


