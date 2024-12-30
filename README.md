# Algorithmic Reverb

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Presets](#presets)
- [Usage](#usage)
- [Interface](#interface)
- [Future Work](#future-work)
- [References](#references)

## Overview

A MATLAB implementation of an algorithmic reverb effect, drawing inspiration from the Spin Semiconductor reverb tank design. This project was developed as part of Master's research into digital signal processing and audio effects.

The implementation provides five key parameter controls:
* Dry/Wet mix (0-100%)
* Early reflections level (0-100%)
* Pre-delay time (0-500ms)
* Dampening amount (0-100%)
* Reverb decay time (0-100%)

## Features

### Primary Influences
* **Spin Semiconductor**: Figure-eight reverb tank design for complex recirculating networks
* **Moorer's Design**: Early reflections model and multi-tap delay approach
* **Dattorro's Work**: Prime-numbered tap points for enhanced diffusion
* **Gerzon's Work**: Feedback delay networks

### Design Elements
* Multi-branch architecture
* Complex feedback routing
* Frequency-dependent decay
* Modulated filters

## Architecture

![Architecture Block Diagram](https://github.com/user-attachments/assets/885f5da8-c0e3-487f-b823-5aee343d9ecc)

The reverb consists of the following components:

### Pre-delay Stage
```
Input → Fixed Delay Line → Output
```
*Adds initial delay between dry signal and reverb onset (0-500ms)*

### Early Reflections Stage
```
Input → Multi-tap Delay Line → Initial Reflection Pattern
```
*Simulates room reflections through both a dedicated multi-tap delay line and prime-numbered taps in the main branches*

### Main Reverb Network

#### Branch Type 1
```
Input → Modulated APF → APF → Low-pass Filter → Fixed Delay → kRT
```
*Uses all-pass filters for increased echo density and a low-pass filter for dampening control*

#### Branch Type 2
```
Input → Modulated APF → APF → Low-pass Comb Filter → Fixed Delay → kRT
```
*Similar to Type 1 but employs a low-pass comb filter for natural decay characteristics*

#### Branch Type 3
```
Input → Modulated Delay → Low-pass Filter → kRT → Low Shelf
```
*Implements modulated delay and filtering to create complex feedback patterns*

### Global Feedback Network
```
Branch 4 Output → Low Shelf → Notch Filter → Branch 1 Input
```
*Creates figure-of-eight circuit through recirculation, with filtering to control frequency buildup*

## Presets

### Hall Preset
```matlab
Reverb Time: 80
Early Reflections: 50  
Pre Delay: 100ms
Dampening: 70
```
*Creates a warm, spacious hall sound with ~1.5s decay time*

### Spring Preset
```matlab
Reverb Time: 70
Early Reflections: 0
Pre Delay: 0ms  
Dampening: 90
```
*Emulates vintage spring reverb characteristics*

### Cathedral Preset
```matlab
Reverb Time: 90
Early Reflections: 20
Pre Delay: 50ms
Dampening: 30
```
*Long decay with sparse early reflections*

## Usage

Basic function call:
```matlab
reverberationProcess(in, Fs, mix, er, preDelay, dampning, reverbTime)
```

### Parameters
- `in`: Input audio array
- `Fs`: Sample rate
- `mix`: Dry/wet ratio (0-100)
- `er`: Early reflections level (0-100)
- `preDelay`: Pre-delay time in ms (0-500)
- `dampning`: High frequency attenuation (0-100)
- `reverbTime`: Reverb decay time (0-100)

### Example
```matlab
[in, Fs] = audioread("input.wav");
reverberationProcess(in, Fs, 40, 50, 100, 70, 80);  % Hall preset
```

## Interface

<img width="635" alt="Reverb UI" src="https://github.com/user-attachments/assets/5c5c67b1-f2d4-4e83-83ed-32fcc6350b51" />
<br>
<br>



**The graphical interface provides**:
* Load/Play controls
* Three rotary knobs:
  * Dry/Wet mix
  * Dampening
  * ER Level
* Slider controls:
  * Pre-delay (0-500ms)
  * Reverb Time (0-100)

## Future Work

Potential improvements:
* RT60-calibrated reverb time control
* Higher-order low-pass filters
* Enhanced modulation options
* More sophisticated early reflection patterns

## References

* Dattorro, J. (1997) 'Effect Design Part 1: Reverberator and Metaverb', *Journal of the Audio Engineering Society*, 45(9), pp. 660-684
* Moorer, J. A. (1979) "About This Reverberation Business." *Computer Music Journal*, Vol. 3, No. 2, pp. 13-28
* Smith, J.O. and Rocchesso, D. (1994) 'Connections between feedback delay networks and waveguide models for musical acoustics', *Proceedings of the International Computer Music Conference*, pp. 376-377
* Spin Semiconductor (2018) Knowledge Base, Effects: Reverberation. Available at: http://www.spinsemi.com/knowledge_base/effects.html#Reverberation
* Tarr, E. (2019) *Hack Audio: An Introduction to Computer Programming and Digital Signal Processing in MATLAB*. New York: Routledge. Audio Engineering Society Presents, vol. 25

## License

This project is provided for educational and research purposes. Code and design may be used with proper attribution.
