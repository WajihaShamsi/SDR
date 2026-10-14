import math
import os

N_SAMPLES = 2048      # ROM depth
WIDTH = 16            # 16-bit output

filename = "instruments/sdr/sinewave.coe"

with open(filename, "w") as f:

    f.write("memory_initialization_radix = 2;\n")
    f.write("memory_initialization_vector =\n")

    for n in range(N_SAMPLES):

        theta = 2 * math.pi * n / N_SAMPLES

        # unsigned 16-bit sine
        value = int(
            ((math.sin(theta) + 1.0) / 2.0)
            * ((2**WIDTH) - 1)
        )

        binary = format(value, f"0{WIDTH}b")

        if n == N_SAMPLES - 1:
            f.write(binary + ";")
        else:
            f.write(binary + ",\n")

print(f"Generated {os.path.abspath(filename)}")