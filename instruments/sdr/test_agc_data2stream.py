
#!/usr/bin/env python3
"""Test the original Data2Stream FIFO format:
Upper 16 bits = GainAdjusted_I
Lower 16 bits = ToSpeaker
"""

import argparse
import os
import time

import numpy as np
import matplotlib.pyplot as plt

from koheron import connect
from sdr import Sdr


def decode(words):
    words = np.asarray(words, dtype=np.uint32).ravel()

    gain_i = ((words >> 16) & 0xFFFF).astype(np.uint16).view(np.int16)
    speaker = (words & 0xFFFF).astype(np.uint16).view(np.int16)

    return gain_i.astype(float), speaker.astype(float)


def spectrum(samples, fs):
    samples = samples - np.mean(samples)
    window = np.hanning(len(samples))

    fft = np.fft.rfft(samples * window)
    freq = np.fft.rfftfreq(len(samples), d=1 / fs)
    amplitude = 2 * np.abs(fft) / window.sum()

    return freq, amplitude


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", default=os.getenv("HOST", "192.168.1.100"))
    parser.add_argument("--frequency", type=int, default=909000)
    parser.add_argument("--sel", type=int, default=9)
    parser.add_argument("--captures", type=int, default=5)
    parser.add_argument("--sample-rate", type=float, default=125e6 / 651 / 6)
    parser.add_argument("--tone", type=float, default=1000.0)
    parser.add_argument("--save", action="store_true")
    args = parser.parse_args()

    driver = Sdr(connect(args.host, name="sdr"))
    driver.set_receive_frequency(args.frequency)
    driver.set_volume(args.sel)

    time.sleep(0.2)

    blocks = [
        np.asarray(driver.get_fifo_buffer(), dtype=np.uint32).ravel()
        for _ in range(args.captures)
    ]
    words = np.concatenate(blocks)

    gain_i, speaker = decode(words)

    fig, axes = plt.subplots(2, 2, figsize=(13, 8))

    for row, (name, samples) in enumerate([
        ("GainAdjusted_I (upper 16 bits)", gain_i),
        ("ToSpeaker (lower 16 bits)", speaker),
    ]):
        freq, amplitude = spectrum(samples, args.sample_rate)

        peak_idx = np.argmax(amplitude[1:]) + 1
        tone_idx = np.argmin(np.abs(freq - args.tone))

        print(f"\n{name}")
        print(f"Min / Max: {samples.min():.0f} / {samples.max():.0f}")
        print(f"Mean: {samples.mean():.2f}")
        print(f"AC RMS: {np.std(samples):.2f}")
        print(f"Dominant frequency: {freq[peak_idx]:.2f} Hz")
        print(f"Dominant amplitude: {amplitude[peak_idx]:.2f} counts")
        print(f"Near 1 kHz: {freq[tone_idx]:.2f} Hz, "
              f"{amplitude[tone_idx]:.2f} counts")

        near_rails = np.count_nonzero(
            (samples >= 32760) | (samples <= -32760)
        )
        print(f"Near-rail samples: {near_rails}/{len(samples)}")

        nshow = min(1024, len(samples))
        t = np.arange(nshow) / args.sample_rate * 1000

        axes[row, 0].plot(t, samples[:nshow], lw=0.8)
        axes[row, 0].set_title(name)
        axes[row, 0].set_xlabel("Time (ms)")
        axes[row, 0].set_ylabel("FIFO counts")

        db = 20 * np.log10(np.maximum(amplitude, 1e-12))
        axes[row, 1].plot(freq, db, lw=0.8)
        axes[row, 1].axvline(args.tone, color="gray", ls="--")
        axes[row, 1].set_xlim(0, 3000)
        axes[row, 1].set_title(f"{name} spectrum")
        axes[row, 1].set_xlabel("Frequency (Hz)")
        axes[row, 1].set_ylabel("Magnitude (dB re 1 count)")

    for ax in axes.flat:
        ax.grid(True, alpha=0.3)

    fig.tight_layout()

    if args.save:
        fig.savefig("data2stream_agc.png", dpi=160)
        words.tofile("data2stream_fifo_raw.bin")
        print("\nSaved plot and raw FIFO data.")

    plt.show()


if __name__ == "__main__":
    main()

