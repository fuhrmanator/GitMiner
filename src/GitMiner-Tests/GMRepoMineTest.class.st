Class {
	#name : #GMRepoMineTest,
	#superclass : #TestCase,
	#category : #'GitMiner-Tests'
}

{ #category : #tests }
GMRepoMineTest >> testCloneRepo [

	| mine url location |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: url.
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
	mine := GMRepoMine fromURL: url.
	self assert: mine rootForClone equals: (FileSystem disk workingDirectory / 'tmp' / 'tempClonesPharo').
	self assert: mine url equals: url.
]

{ #category : #tests }
GMRepoMineTest >> testGitHubProjectName [

	| mine url |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: url.
	self assert: mine gitHubProjectName equals: 'fuhrmanator.FactoryVariants'.

]

{ #category : #tests }
GMRepoMineTest >> testProjectName [

	| mine url |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: url.
	self assert: mine projectName equals: 'FactoryVariants'.

]

{ #category : #tests }
GMRepoMineTest >> testRootForClone [

	| mine url root |
	root := FileSystem workingDirectory / 'myTemp'.
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: url rootForClone: root.
	self assert: mine rootForClone equals: root.

]

{ #category : #tests }
GMRepoMineTest >> testUrl [

	| mine url |
	url := 'https://github.com/fuhrmanator/FactoryVariants'.
	mine := GMRepoMine fromURL: url.
	self assert: mine url equals: url.

]
