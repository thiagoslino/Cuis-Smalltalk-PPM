# Cuis-Smalltalk-PPM
A simple ImageReadWriter subclass for reading and writing **PPM (Portable Pixmap)** images in Cuis Smalltalk.

Reference: https://netpbm.sourceforge.net/doc/ppm.html

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
<img width="869" height="480" alt="saida" src="https://github.com/user-attachments/assets/9093b838-664a-40fd-ba62-13fdd7f217e8" />
