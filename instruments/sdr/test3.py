
#!/usr/bin/env python3

import os
import numpy as np
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt

from sdr import Sdr
from koheron import connect

HOST = os.getenv("HOST", "192.168.1.100")
FS = 32000.0  # Assumed FIFO sample rate; verify in FPGA
N = 1024

client = connect(HOST, name="sdr")
driver = Sdr(client)

driver.set_receive_frequency(909000)
driver.set_volume(9)

plt.ion()

fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(11, 9))

time_ms = np.arange(N) / FS * 1000

line1, = ax1.plot(time_ms, np.zeros(N), lw=0.8)
line2, = ax2.plot(time_ms, np.zeros(N), lw=0.8)

freq = np.fft.rfftfreq(N, d=1 / FS)
line3, = ax3.plot(freq, np.zeros(len(freq)), lw=1)

ax1.set_title("Gain-adjusted I")
ax1.set_ylabel("ADC / FPGA counts")
ax1.set_ylim(-32768, 32767)

ax2.set_title("Speaker signal")
ax2.set_ylabel("FPGA counts")
ax2.set_ylim(-32768, 32767)

ax3.set_title("Speaker spectrum")
ax3.set_xlabel("Baseband frequency (Hz)")
ax3.set_ylabel("Relative FFT magnitude (dB)")
ax3.set_xlim(0, FS / 2)
ax3.set_ylim(-100, 0)

for ax in (ax1, ax2, ax3):
    ax.grid(True, alpha=0.3)

plt.tight_layout()

while plt.fignum_exists(fig.number):
    try:
        raw = np.asarray(driver.get_fifo_buffer())

        if raw.size != N:
            print(f"Unexpected buffer size: {raw.size}")
            continue

        # Interpret each FIFO word as 32 unsigned bits.
        words = raw.astype(np.uint32)

        # Extract lower and upper 16-bit fields.
        speaker_u16 = (words & 0xFFFF).astype(np.uint16)
        gain_u16 = ((words >> 16) & 0xFFFF).astype(np.uint16)

        # Reinterpret bit patterns as signed two's-complement.
        speaker = speaker_u16.view(np.int16).astype(np.float64)
        gain_i = gain_u16.view(np.int16).astype(np.float64)

        # Remove DC for FFT analysis only.
        signal = gain_i - np.mean(gain_i)

        # Hann window reduces spectral leakage.
        window = np.hanning(N)

        spectrum = np.abs(np.fft.rfft(signal * window))

        # Relative dB: strongest bin = 0 dB.
        spectrum_db = 20 * np.log10(
            np.maximum(spectrum, 1e-12)
        )
        spectrum_db -= np.max(spectrum_db)

        # Find strongest non-DC bin.
        peak_bin = np.argmax(spectrum[1:]) + 1
        peak_hz = freq[peak_bin]

        print(
            f"Gain I: min={gain_i.min():.0f}, "
            f"max={gain_i.max():.0f} | "
            f"Speaker: min={speaker.min():.0f}, "
            f"max={speaker.max():.0f} | "
            f"FFT peak={peak_hz:.1f} Hz"
        )

        line1.set_ydata(gain_i)
        line2.set_ydata(speaker)
        line3.set_ydata(spectrum_db)

        fig.canvas.draw_idle()
        plt.pause(0.05)

    except KeyboardInterrupt:
        break

plt.close("all")

