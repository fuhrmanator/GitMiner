Class {
	#name : #GMRepoMineTest,
	#superclass : #TestCase,
	#category : #'GitMiner-Tests'
}

{ #category : #tests }
GMRepoMineTest >> testCloneRepo [

	| mine url location |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: 'https://github.com/fuhrmanator/FactoryVariants'.
	"delete the test repo if it exists"
	location := mine rootForClone / mine projectName.
	location ensureDeleteAll.
	
	location := mine cloneRepo.
	self assert: location exists.

	
]

{ #category : #tests }
GMRepoMineTest >> testCreationFromURL [
	"comment stating purpose of message"

	| mine url |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: 'https://github.com/fuhrmanator/FactoryVariants'.
	self assert: mine rootForClone equals: (FileSystem disk workingDirectory / 'tmp' / 'tempClonesPharo').
	self assert: mine url equals: url.
]

{ #category : #tests }
GMRepoMineTest >> testRootForClone [

	| mine url root |
	root := FileSystem workingDirectory / 'myTemp'.
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: 'https://github.com/fuhrmanator/FactoryVariants' rootForClone: root.
	self assert: mine rootForClone equals: root.

]
