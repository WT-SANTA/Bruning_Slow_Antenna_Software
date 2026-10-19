#!/usr/bin/env python3
# Plots slow antenna "raw" files

import numpy as np
import argparse
from slow_antenna_processing_scripts import sa_common
import plotext as plt

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Plot Slow Antenna .raw data')
    parser.add_argument('-i', '--input', nargs='+', required=True,
                        help='Path or paths to slow antenna files to plot')
    args = parser.parse_args()
    filenames = sorted(args.input)
    all_data = []
    all_times = []
    for i, filename in enumerate(filenames):
        if i == 0:
            this_file = sa_common.read_SA_file(filename)
        else:
            this_file = sa_common.read_SA_file(filename, previous_file=filenames[i-1])
        this_times, this_data = sa_common.decode_SA_array(this_file)
        all_times.append(this_times)
        all_data.append(this_data)
    adc = np.concatenate(all_data, axis=0)
    adc_ready = np.concatenate(all_times, axis=0)

    delta_t_adc = (adc_ready[-1]-adc_ready[0])*1e-6
    sample_rate = 1.0e6/np.median(np.ediff1d(adc_ready))
    print(
        f"Elapsed time {delta_t_adc:6.3} s with sample rate {sample_rate:6.1f} Hz")

    t = np.arange(adc.shape[0])/sample_rate

    bits_to_volts = (5/((2**24)-1))
    volts = adc*bits_to_volts

    plt.clf()
    plt.theme('clear')
    plt.plot(t, volts, color='blue')
    plt.title('ADC (filtered)')
    plt.xlabel('Time (s)')
    plt.ylabel('Volts')
    plt.show()
