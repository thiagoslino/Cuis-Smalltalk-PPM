# Cuis-Smalltalk-PPM
A simple ImageReadWriter subclass for reading and writing **PPM (Portable Pixmap)** images in Cuis Smalltalk.

## Features

- ✅ Reads **P3 (ASCII)** and **P6 (binary)** PPM formats
- ✅ Writes **P6 (binary)** format (compact and standard)
- ✅ Handles header comments (`#`)
- ✅ Supports `maxval` up to 255 (8-bit per channel)
- ✅ Seamless integration with Cuis `ImageReadWriter` framework

## Usage

```smalltalk
"Load this package"
Feature require: 'PPM'.

"Read a PPM image (P3 or P6)"
myForm := ImageReadWriter formFromFileNamed: 'image.ppm'.

"Write a Form as PPM (P6 binary)"
PPMReadWriter putForm: myForm onFileNamed: 'output.ppm'.

"Open an ImageMorph"
ImageMorph fromFileNamed: 'image.ppm' :: scaleBy: 0.5 :: openInWorld.
```
<img width="1452" height="796" alt="ppm-usage" src="https://github.com/user-attachments/assets/74b7a0c4-23fe-4284-9ad4-76d2982e090c" />

