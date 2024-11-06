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
  - Catmandu - This uses catmandu like this: catmandu convert MARC --type XML to MARC --type ALEPHSEQ < BIBLIOGRAPHIC_65311492130002791_65311492110002791_1.xml > BIBLIOGRAPHIC_65311492130002791_65311492110002791_1.sav
  - To perform the file conversions specified in the program - I am using Catmandu. It needs the following Catmandu modules:
  - Catmandu (The core module for Catmandu)
Catmandu::MARC (For handling MARC records, including conversion between MARC formats)
Catmandu::XML (For handling XML files)

You can install these modules using cpan or cpanm. Here are the commands to install them:

cpan install Catmandu Catmandu::MARC Catmandu::XML


Or, if you are using cpanm:

```cpanm Catmandu Catmandu::MARC Catmandu::XML
```

These modules will enable you to use the catmandu convert commands in your script to convert between XML, MARC, and AlephSEQ formats. 

## Installation

1. **Install Perl**: Download and install Strawberry Perl from strawberryperl.com.

2. **Install Required Modules**:
   ```sh
   cpan install Tk Tk::FileSelect Win32::GUI File::Slurp PAR::Packer
```
   .....

# Creating executable exe for Windows

I created in Windows 10 as follows - in CMD:

```sh
pp -M Tk -M Tk::FileSelect -M Win32::GUI -M File::Slurp -o  aaa_pl_mrc_seq_004.exe aaa_pl_mrc_seq_004.pl
```
.


