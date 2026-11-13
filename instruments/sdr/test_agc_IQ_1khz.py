#!/usr/bin/env python3
"""Live Koheron AGC I/Q capture and 1 kHz tone check."""
import argparse
import os
import time
import numpy as np


def unpack_iq(words):
    """FIFO: [31:16] = Q, [15:0] = I, signed 16-bit."""
    w = np.asarray(words, dtype=np.uint32).ravel()
    i = (w & 0xffff).astype(np.uint16).view(np.int16).astype(np.float64)
    q = (w >> 16).astype(np.uint16).view(np.int16).astype(np.float64)
    return i, q, w


def spectrum(x, fs):
    x = np.asarray(x, dtype=np.float64)
    if len(x) < 4:
        raise ValueError('Not enough samples for FFT')
    window = np.hanning(len(x))
    fft = np.fft.rfft((x - np.mean(x)) * window)
    amp = 2 * np.abs(fft) / max(window.sum(), 1)
    freqs = np.fft.rfftfreq(len(x), 1 / fs)
    return freqs, amp


def describe(name, samples, fs, tone, tolerance):
    f, amp = spectrum(samples, fs)
    valid = f > 0
    peak_idx = np.flatnonzero(valid)[np.argmax(amp[valid])]
    near = np.flatnonzero((f >= max(0, tone - tolerance)) & (f <= tone + tolerance))
    if len(near):
        tone_idx = near[np.argmax(amp[near])]
        tone_result = f'{f[tone_idx]:.1f} Hz, amplitude {amp[tone_idx]:.3f}'
    else:
        tone_result = 'no FFT bins within tolerance'
    print(f'  {name}: RMS={np.std(samples):.3f}, peak={np.max(np.abs(samples)):.0f}, '
          f'dominant={f[peak_idx]:.1f} Hz (amplitude {amp[peak_idx]:.3f}), '
          f'near {tone:g} Hz: {tone_result}')
    return f, amp


def main():
    p = argparse.ArgumentParser(description='Capture AGC I/Q FIFO and inspect 1 kHz tone')
    p.add_argument('--host', default=os.getenv('HOST', '192.168.1.100'))
    p.add_argument('--instrument', default='sdr')
    p.add_argument('--frequency', type=int, default=909000)
    p.add_argument('--sel', nargs='+', type=int, default=[5, 6, 7, 8, 9])
    p.add_argument('--captures', type=int, default=5)
    p.add_argument('--settle', type=float, default=0.2)
    p.add_argument('--sample-rate', type=float, default=125e6 / 651 / 6)
    p.add_argument('--tone', type=float, default=1000.0)
    p.add_argument('--tolerance', type=float, default=100.0)
    p.add_argument('--plot', action='store_true')
    p.add_argument('--save', action='store_true')
    args = p.parse_args()
    if any(s not in range(16) for s in args.sel):
        p.error('AGC selectors must be 0..15')
    if args.captures < 1 or args.sample_rate <= 0 or args.tolerance <= 0:
        p.error('captures, sample-rate and tolerance must be positive')

    from koheron import connect
    from sdr import Sdr
    print(f'Connecting to {args.host}, instrument {args.instrument} ...', flush=True)
    print(f'Assumed FIFO sample rate: {args.sample_rate:.3f} Hz (verify against FPGA)', flush=True)
    driver = Sdr(connect(args.host, name=args.instrument))
    driver.set_receive_frequency(args.frequency)
    results = []
    for sel in args.sel:
        driver.set_volume(sel)
        time.sleep(args.settle)
        blocks = []
        for _ in range(args.captures):
            blocks.append(np.asarray(driver.get_fifo_buffer(), dtype=np.uint32).ravel())
        words = np.concatenate(blocks)
        i, q, words = unpack_iq(words)
        print(f'\nsel={sel}, {len(words)} samples:', flush=True)
        fi, ai = describe('I (low16)', i, args.sample_rate, args.tone, args.tolerance)
        fq, aq = describe('Q (high16)', q, args.sample_rate, args.tone, args.tolerance)
        results.append((sel, i, q, fi, ai, fq, aq))
        if args.save:
            filename = f'capture_sel{sel}_iq.bin'
            words.tofile(filename)
            print(f'  Saved {filename}')

    if args.plot or args.save:
        import matplotlib.pyplot as plt
        fig, axes = plt.subplots(2, 2, figsize=(13, 8))
        for sel, i, q, fi, ai, fq, aq in results:
            nshow = min(1024, len(i))
            axes[0, 0].plot(np.arange(nshow) / args.sample_rate * 1000, i[:nshow], label=f'sel {sel}', alpha=.8)
            axes[1, 0].plot(np.arange(nshow) / args.sample_rate * 1000, q[:nshow], label=f'sel {sel}', alpha=.8)
            axes[0, 1].plot(fi, 20 * np.log10(np.maximum(ai, 1e-12)), label=f'sel {sel}')
            axes[1, 1].plot(fq, 20 * np.log10(np.maximum(aq, 1e-12)), label=f'sel {sel}')
        axes[0, 0].set_title('AGC I — low 16 bits')
        axes[1, 0].set_title('AGC Q — high 16 bits')
        axes[0, 1].set_title('I spectrum')
        axes[1, 1].set_title('Q spectrum')
        for ax in (axes[0, 0], axes[1, 0]):
            ax.set_xlabel('Time (ms)')
            ax.set_ylabel('ADC/FIFO counts')
        for ax in (axes[0, 1], axes[1, 1]):
            ax.set_xlabel('Frequency (Hz)')
            ax.set_ylabel('Magnitude (dB re 1 count)')
            ax.axvline(args.tone, color='black', linestyle='--', alpha=.6, label=f'{args.tone:g} Hz')
            ax.set_xlim(0, min(args.sample_rate / 2, max(3000, args.tone * 3)))
        for ax in axes.flat:
            ax.grid(True, alpha=.25)
            ax.legend(fontsize=8)
        fig.tight_layout()
        if args.save:
            fig.savefig('agc_iq_1khz.png', dpi=160)
            print('\nSaved agc_iq_1khz.png', flush=True)
        if args.plot:
            plt.show()
        else:
            plt.close(fig)


if __name__ == '__main__':
    main()
