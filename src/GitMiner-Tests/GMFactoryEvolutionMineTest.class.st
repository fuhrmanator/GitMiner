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

{ #category : #test }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementations [

	| iMine assignmentsOfImplementations |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.

	assignmentsOfImplementations := iMine assignmentsOfImplementations.
	0halt.

	self
		assert: assignmentsOfImplementations notEmpty.
]

{ #category : #tests }
GMFactoryEvolutionMineTest >> testAssignmentsOfImplementationsWithNoInterface [
	| iMine |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.

	"iMine sourceFolder: (FileSystem disk workingDirectory) / 'tmp' / 'data_mining' / 'FactoryVariants_master' / 'HEAD'."
	self
		assert: iMine assignmentsOfImplementationsWithNoInterface notEmpty
]

{ #category : #test }
GMFactoryEvolutionMineTest >> testConstructors [
	| iMine constructors |
	iMine := GMFactoryEvolutionMine fromMSE: mseFile.
	iMine load.
	iMine sourceFolder: (mseFile parent / mseFile basenameWithoutExtension) fullName.	
	constructors := iMine constructors.
	
	self assert: constructors anyOne isConstructor.
	self assert: constructors anyOne isMethod.
]
