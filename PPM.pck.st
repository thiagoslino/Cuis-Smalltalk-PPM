'From Cuis7.9 [latest update: #8014] on 19 June 2026 at 9:17:32 am'!
'Description '!
!provides: 'PPM' 1 1!
SystemOrganization addCategory: #PPM!


!classDefinition: #PPMReadWriter category: #PPM!
ImageReadWriter subclass: #PPMReadWriter
	instanceVariableNames: 'width height maxValue magicNumber'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'PPM'!
!classDefinition: 'PPMReadWriter class' category: #PPM!
PPMReadWriter class
	instanceVariableNames: ''!


!PPMReadWriter commentStamp: '<historical>' prior: 0!
I am a subclass of ImageReadWriter that reads and writes PPM (Portable Pixmap) images. 
I support reading both P3 (ASCII) and P6 (binary) formats, and writing in P6 (binary) format. 
I handle header comments (#) and support color component values (maxval) up to 255.

See https://netpbm.sourceforge.net/doc/ppm.html!

!PPMReadWriter methodsFor: 'testing' stamp: 'tsl 18/Jun/2026, 11:10:53 am (UTC)'!
understandsImageFormat
	| magic |
	magic := self readTokenFrom: stream.
	^ (magic = 'P3' or: [magic = 'P6'])! !

!PPMReadWriter methodsFor: 'accessing' stamp: 'tsl 18/Jun/2026, 11:03:13 am (UTC)'!
nextImage
	self readHeader.
	^ self readPixels! !

!PPMReadWriter methodsFor: 'accessing' stamp: 'tsl 18/Jun/2026, 11:03:21 am (UTC)'!
nextPutImage: aForm
	self writeP6: aForm! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 18/Jun/2026, 4:49:36 pm (UTC)'!
readHeader
	"The header is textual, but the stream may be in binary mode. 
	The readTokenFrom: method handles both modes."

	magicNumber := self readTokenFrom: stream.
	(magicNumber = 'P3' or: [magicNumber = 'P6'])
		ifFalse: [self error: 'Unsupported PPM format. Expected P3 or P6'].
	width := (self readTokenFrom: stream) asNumber.
	height := (self readTokenFrom: stream) asNumber.
	maxValue := (self readTokenFrom: stream) asNumber.

	maxValue > 255 ifTrue: [self error: 'maxval > 255 not supported'].! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 18/Jun/2026, 4:28:04 pm (UTC)'!
readP3Pixels
    | pixelCount form |

    pixelCount := width * height.
    form := Form extent: width @ height depth: 32.
    1 to: pixelCount do: [ :i | | r g b pixelWord |
        r := (self readTokenFrom: stream) asNumber.
        g := (self readTokenFrom: stream) asNumber.
        b := (self readTokenFrom: stream) asNumber.
        pixelWord := (r bitShift: 16) bitOr: (g bitShift: 8) :: bitOr: b :: bitOr: (255 bitShift: 24).
        form bits at: i put: pixelWord ].
    ^ form! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 18/Jun/2026, 4:28:27 pm (UTC)'!
readP6Pixels
    | pixelCount pixelBytes form |

    pixelCount := width * height.
    stream binary.
    pixelBytes := stream next: (pixelCount * 3).

    form := Form extent: width @ height depth: 32.
    1 to: pixelCount do: [ :i | | base r g b pixelWord |
        base := (i - 1) * 3.
        r := pixelBytes at: base + 1.
        g := pixelBytes at: base + 2.
        b := pixelBytes at: base + 3.
        pixelWord := (r bitShift: 16) bitOr: (g bitShift: 8) :: bitOr: b :: bitOr: (255 bitShift: 24).
        form bits at: i put: pixelWord ].
    ^ form! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 18/Jun/2026, 11:04:01 am (UTC)'!
readPixels
	magicNumber = 'P3'
		ifTrue: [^ self readP3Pixels]
		ifFalse: [^ self readP6Pixels]! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 17/Jun/2026, 6:34:10 pm (UTC)'!
readTokenFrom: aStream
	"Reads the next token from the header, ignoring comments (#) and whitespace.
	Works in both text and binary mode."
	| tokenStream value char |

	tokenStream := WriteStream on: ''.
	[ aStream atEnd ] whileFalse: [
		value := aStream next.
		"Convert to Character if the stream is in binary mode"
		char := (value isKindOf: Character)
			ifTrue: [ value ]
			ifFalse: [ Character codePoint: value ].

		char = $# ifTrue: [
			"Skip the rest of the line"
			[ aStream atEnd or: [
				| nextVal |
				nextVal := aStream next.
				((nextVal isKindOf: Character)
					ifTrue: [ nextVal ]
					ifFalse: [ Character codePoint: nextVal ]) = Character lf
			]] whileFalse.
			^ self readTokenFrom: aStream
		].

		char isSeparator
			ifTrue: [ tokenStream size > 0 ifTrue: [ ^ tokenStream contents ] ]
			ifFalse: [ tokenStream nextPut: char ]
	].
	^ tokenStream contents! !

!PPMReadWriter methodsFor: 'image reading/writing' stamp: 'tsl 18/Jun/2026, 11:14:49 am (UTC)'!
writeP6: aForm
    | pixelCount pixelArray formBits |

    stream binary.
    width := aForm width.
    height := aForm height.
    pixelCount := width * height.

    stream nextPutAll: 'P6'; cr.
    stream nextPutAll: width printString; space; nextPutAll: height printString; cr.
    stream nextPutAll: '255'; cr.

    formBits := aForm bits.
    pixelArray := ByteArray new: pixelCount * 3.
    1 to: pixelCount do: [ :i |
        | pixelWord base offset |
        pixelWord := formBits at: i.
        base := (i - 1) * 4.
        offset := (i - 1) * 3.
        pixelArray
            at: offset + 1 put: ((pixelWord bitShift: -16) bitAnd: 16rFF);
            at: offset + 2 put: ((pixelWord bitShift: -8) bitAnd: 16rFF);
            at: offset + 3 put: (pixelWord bitAnd: 16rFF) ].
    stream nextPutAll: pixelArray! !

!PPMReadWriter class methodsFor: 'image reading/writing' stamp: 'tsl 17/Jun/2026, 6:23:36 pm (UTC)'!
typicalFileExtensions
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('ppm')! !
