# EEG-Arthromotor Integration Project
This repository contains the code, documentation, and 3D printed models necessary for replicating the EEG-Arthromotor integration study. This project investigates the interaction between 
sensorimotor and emotional brain processing in individuals with neurodevelopmental disorders using a novel, non-invasive add-on to an existing EEG recording system.

## Project structure
The repository is organized as follows:

* `MATLAB/`: Contains the MATLAB scripts for managing the experimental protocol, presenting stimuli, and synchronizing EEG recordings.

* `ESP32/`: Contains the code for the ESP-32 microcontroller that controls the mechanical arthromotor.

* `3DModels/`: Contains STL files and documentation for the 3D printed parts of the arthromotor.

* `Docs/`: Contains detailed documentation on the experimental setup, software installation, and usage instructions.

* `LICENSE`: The project's open-source license.

* `README.md`: This readme file.


## Prerequisites

MATLAB (with necessary toolboxes)
VSCode + Platformio or Arduino IDE (for ESP-32 programming)

## Usage

Assemble the Arthromotor: Use the 3D printed parts and assembly instructions found in the 3DModels/ directory.
The 3DModels/ directory contains all necessary STL files for the components of the arthromotor. Detailed assembly instructions are provided in Docs/3DModel_Instructions.pdf.

Run the MATLAB script: Open the MATLAB/main_experiment.m script and run it to start the experimental protocol.

Collect Data: The MATLAB script will present stimuli, control the arthromotor, and synchronize event markers with the EEG data.

Analyze Data: Use your preferred EEG analysis tools to interpret the collected data.


## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing
We welcome contributions to this project! Please see Docs/CONTRIBUTING.md for guidelines on how to contribute.

## Acknowledgments
This project was developed as part of a study on neurodevelopmental disorders. Special thanks to all the researchers and participants involved in this study.
