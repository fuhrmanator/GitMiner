Class {
	#name : #GMInterfaceMineTest,
	#superclass : #TestCase,
	#category : #'GitMiner-Tests'
}

{ #category : #tests }
GMInterfaceMineTest >> testCreationFromMSE [
	"create a mine from an mseFile"
	| iMine mseFile |
	mseFile := FileSystem disk workingDirectory / 'pharo-local' / 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests' / 'FactoryVariants.mse'.
	self assert: mseFile exists.
	iMine := GMInterfaceMine fromMSE: mseFile.
	self assert: iMine isNotNil.
	self assert: iMine mseFile equals: mseFile.
]

{ #category : #tests }
GMInterfaceMineTest >> testLoad [
	"create a mine from an mseFile"
	| iMine mseFile |
	mseFile := FileSystem disk workingDirectory / 'pharo-local' / 'iceberg' / 'fuhrmanator' / 'GitMiner' / 'tests' / 'FactoryVariants.mse'.
	self assert: mseFile exists.
	iMine := GMInterfaceMine fromMSE: mseFile.
	iMine load.
	self assert: iMine isLoaded.
	self assert: iMine interfaces size equals: 8.

]
