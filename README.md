# Solar-cell-parameter-extraction-code
A solar cell parameter extraction based on both characteristics of the device implemented for Octave package. This performs an extraction of the solar cell's parameters model, based on the two diode model.

There are two main programs, iluminacion and oscuridad corresponding to the illumination and dark I-V approximation resectivelly. The ilumination code mut be run first, a CSV file where the input data (Voc, Isc, Vmpp and Impp) must be provided. Once the illumintacion execution finishes, oscuridad file can be executed after this, the process is repeated again until the change between parameters are minimum.
