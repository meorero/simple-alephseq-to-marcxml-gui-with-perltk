# simple-alephseq-to-marcxml-gui-with-perltk# File Converter GUI

This project is a Perl-based GUI application for converting files between different formats using `Catmandu`. The GUI is built using the `Tk` module and includes functionality for selecting files, converting them, and saving the output.

## Features

- Select files of types: XML, MRC, SAV, or any file type.
- Convert XML to AlephSEQ.
- Convert MRC to MARC XML.
- Convert AlephSEQ to MRC.
- Clear the output display.
- Save the output to a file.
- Display help information.

## Prerequisites

- Perl (Strawberry Perl recommended for Windows)
- `PAR::Packer` for creating the standalone executable
- Required Perl modules:
  - `Tk`
  - `Tk::FileSelect`
  - `Win32::GUI`
  - `File::Slurp`

## Installation

1. **Install Perl**: Download and install Strawberry Perl from strawberryperl.com.

2. **Install Required Modules**:
   ```sh
   cpan install Tk Tk::FileSelect Win32::GUI File::Slurp PAR::Packer
