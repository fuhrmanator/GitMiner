"
A GMFactoryEvolutionMineTest is a test class for testing the behavior of GMFactoryEvolutionMine
"
Class {
	#name : #GMFactoryEvolutionMineTest,
	#superclass : #GMAbstractMineTest,
	#category : #'GitMiner-Tests'
}

{ #category : #running }
GMFactoryEvolutionMineTest >> setUp [
	"Hooks that subclasses may override to define the fixture of test."

	super setUp.

]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementationsWithNoInterface [
	| iMine |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (FileSystem disk workingDirectory) / 'tmp' / 'data_mining' / 'FactoryVariants_master' / 'HEAD'.
	self
		assert: iMine assignmentsOfImplementationsWithNoInterface notEmpty
]
