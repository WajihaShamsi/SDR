#!/usr/bin/env python3
"""Live Koheron SDR Data2Stream FIFO monitor.

Assumes FIFO word [31:16] = GainAdjusted_I, [15:0] = ToSpeaker.
This is not the alternative AGC-mux I/Q packing.
"""
import argparse
import os
import time

import numpy as np


def decode(words):
    words = np.asarray(words, dtype=np.uint32).ravel()
    speaker = (words & 0xFFFF).astype(np.uint16).view(np.int16).astype(np.float64)
    gain_i = ((words >> 16) & 0xFFFF).astype(np.uint16).view(np.int16).astype(np.float64)
    return gain_i, speaker


def spectrum(samples, fs):
    centered = samples - np.mean(samples)
    window = np.hanning(len(samples))
    amplitude = 2.0 * np.abs(np.fft.rfft(centered * window)) / window.sum()
    freq = np.fft.rfftfreq(len(samples), d=1.0 / fs)
    db = 20.0 * np.log10(np.maximum(amplitude, 1e-12))
    return freq, db


def main():
    parser = argparse.ArgumentParser(description='Live Data2Stream AGC monitor')
    parser.add_argument('--host', default=os.getenv('HOST', '192.168.1.100'))
    parser.add_argument('--frequency', type=int, default=909000)
    parser.add_argument('--sel', type=int, default=9, help='set_volume value; may select FPGA mux')
    parser.add_argument('--captures', type=int, default=5, help='FIFO buffers per update')
    parser.add_argument('--settle', type=float, default=0.2)
    parser.add_argument('--sample-rate', type=float, default=125e6 / 651 / 6,
                        help='Assumed FIFO sample rate in Hz; verify against FPGA')
    parser.add_argument('--tone', type=float, default=1000.0)
    parser.add_argument('--interval', type=float, default=0.2,
                        help='Minimum delay between updates in seconds')
    parser.add_argument('--samples', type=int, default=1024,
                        help='Number of recent samples shown in time plots')
    parser.add_argument('--spectrum-max', type=float, default=None,
                        help='Maximum displayed spectrum frequency in Hz')
    parser.add_argument('--ylim', type=float, default=32000,
                    help='Symmetric Y-axis limit for time plots')
    args = parser.parse_args()
    if (args.captures < 1 or args.sample_rate <= 0 or args.interval < 0
            or args.settle < 0 or args.samples < 4):
        parser.error('captures/sample-rate/samples must be positive; interval/settle nonnegative')

    import matplotlib.pyplot as plt
    from koheron import connect
    from sdr import Sdr

    driver = Sdr(connect(args.host, name='sdr'))
    driver.set_receive_frequency(args.frequency)
    driver.set_volume(args.sel)
    time.sleep(args.settle)

    plt.ion()
    fig, axes = plt.subplots(2, 2, figsize=(13, 8))
    titles = ['GainAdjusted_I — upper 16 bits', 'GainAdjusted_I spectrum',
              'ToSpeaker — lower 16 bits', 'ToSpeaker spectrum']
    for ax, title in zip(axes.flat, titles):
        ax.set_title(title)
        ax.grid(True, alpha=0.25)
    for ax in axes[:, 0]:
        ax.set_xlabel('Time (ms)')
        ax.set_ylabel('Signed FIFO counts')
        ax.set_ylim(-args.ylim, args.ylim)
    max_freq = args.spectrum_max if args.spectrum_max is not None else max(3000.0, 3 * args.tone)
    max_freq = min(max_freq, args.sample_rate / 2)
    for ax in axes[:, 1]:
        ax.set_xlabel('Frequency (Hz)')
        ax.set_ylabel('Amplitude (dB re 1 count)')
        ax.set_xlim(0, max_freq)
        ax.set_ylim(-40, 100)
        ax.axvline(args.tone, color='gray', linestyle='--', alpha=0.6)
    time_lines = [axes[0, 0].plot([], [], lw=0.9)[0],
                  axes[1, 0].plot([], [], lw=0.9)[0]]
    spec_lines = [axes[0, 1].plot([], [], lw=0.9)[0],
                  axes[1, 1].plot([], [], lw=0.9)[0]]
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    print('Live monitoring started. Close the plot window or press Ctrl+C to stop.')
    print('Packing: upper16=GainAdjusted_I; lower16=ToSpeaker')
    update = 0
    try:
        while plt.fignum_exists(fig.number):
            started = time.monotonic()
            blocks = [np.asarray(driver.get_fifo_buffer(), dtype=np.uint32).ravel()
                      for _ in range(args.captures)]
            words = np.concatenate(blocks)
            if words.size < 4:
                print('Skipping empty/short capture')
                plt.pause(0.05)
                continue
            gain_i, speaker = decode(words)
            nshow = min(args.samples, len(words))
            t_ms = np.arange(nshow) * 1000.0 / args.sample_rate
            for line, data in zip(time_lines, (gain_i, speaker)):
                line.set_data(t_ms, data[-nshow:])
            for ax in axes[:, 0]:
                ax.set_xlim(0, max(float(t_ms[-1]), 1e-6))
            for line, data in zip(spec_lines, (gain_i, speaker)):
                f, db = spectrum(data, args.sample_rate)
                line.set_data(f, db)
            update += 1
            fig.suptitle(f'Data2Stream LIVE | LO {args.frequency/1000:g} kHz | '
                         f'set_volume={args.sel} | update {update} | '
                         f'I RMS={np.std(gain_i):.1f}, Speaker RMS={np.std(speaker):.1f}')
            fig.canvas.draw_idle()
            plt.pause(max(0.01, args.interval - (time.monotonic() - started)))
    except KeyboardInterrupt:
        print('\nStopped live monitoring.')
    finally:
        plt.close(fig)


if __name__ == '__main__':
    main()
