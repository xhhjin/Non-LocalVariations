function [Smin, Smax] = ComputeMinMaxScales(MinPsz, MaxPsz, Psz, sf)

Smin = ceil(log10(Psz/MinPsz)/log10(sf));

Smax = ceil(log10(Psz/MaxPsz)/log10(sf));