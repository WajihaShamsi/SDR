#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import matplotlib
matplotlib.use('TKAgg')
from matplotlib import pyplot as plt
import os
import time

from sdr import Sdr
from koheron import connect

host = os.getenv('HOST', '192.168.1.100')
client = connect(host, name='sdr')
driver = Sdr(client)


n=1024

# Set radio freq (Radio S) and volume:
driver.set_receive_frequency(909000)
driver.set_volume(9)

# Dynamic plot
fig = plt.figure()
ax1 = fig.add_subplot(311)
ax2 = fig.add_subplot(312)
ax3 = fig.add_subplot(313)

x = np.arange(n)
y = np.zeros(n)
li1, = ax1.plot(x, y)
li2, = ax2.plot(x, y)
li3, = ax3.plot(x, y)
ax1.set_ylim((-2**13, 2**13))
ax2.set_ylim((-2**13, 2**13))
ax3.set_ylim((80, 150))

ax1.set_xlabel('FIFO sample number')
ax1.set_ylabel('Signal after gain control I')
ax2.set_xlabel('FIFO sample number')
ax2.set_ylabel('Speaker signal')
ax3.set_ylabel('Spectrum of speaker signal dB')
ax3.set_xlabel('Frequency 32 kHz full scale')
fig.canvas.draw()
print('enterring loop')
while True:
    try:
        data_rcv = driver.get_fifo_buffer()
        ToSpeaker = (np.int32(data_rcv % (2**16)) )  #16384) - 8192) % 16384 - 8192
        GainAdjusted_I = np.int32((data_rcv//(2**16)) % 2**16)   #16384) - 8192) % 16384 - 8192
        print("Speaker:", np.min(ToSpeaker), np.max(ToSpeaker))
        print("Gain-adjusted I:", np.min(GainAdjusted_I), np.max(GainAdjusted_I))
        print(driver.get_fifo_length(), np.mean(GainAdjusted_I), np.mean(GainAdjusted_I))
        neg=np.nonzero(GainAdjusted_I>(2**15))
        GainAdjusted_I[neg]=GainAdjusted_I[neg]-(2**16)
        li1.set_ydata(GainAdjusted_I)
        neg=np.nonzero(ToSpeaker>(2**15))
        ToSpeaker[neg]=ToSpeaker[neg]-(2**16)
        li2.set_ydata(ToSpeaker)
        li3.set_ydata(20*np.log10(np.absolute(np.fft.fft(ToSpeaker))))
        fig.canvas.draw()
        plt.pause(0.001)
    except KeyboardInterrupt:
        break
