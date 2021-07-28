This implements the Vector Dot Product of 2 Vectors of same length with length being a parameter to be varied and size of the element in the matrix is also defined as a parameter(using typedef) and can be varied.

Input from Software to hardware is always a 64-bit number, depening on the size of each element in the vector and size of the vector, the number of inputs need to be provided to hardware changes.

### Example-1:
            size of each element = 16 bits
            vector length = 4
            then, the number of 64-bit inputs to be sent to hardware = 64bits (i.e., 1-number)
In the code provided,
```
            size of each element = 16 bits
            vector length = 8
            then, the number of 64-bit inputs to be sent to hardware = 4
```

Output will be a scalar quantity in this case is a 64-bit number.
