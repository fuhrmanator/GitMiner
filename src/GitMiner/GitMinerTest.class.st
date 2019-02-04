Class {
	#name : #GitMinerTest,
	#superclass : #TestCase,
	#category : #'GitMiner-Tests'
}

{ #category : #tests }
GitMinerTest >> testEnvironmentVariables [
	| path |
	path := OSEnvironment current
		at: 'JDT2FAMIXCOMMAND'
		ifAbsent: [ nil ].
	self assert: path isNotNil.
	self assert: path isNotEmpty.
	self assert: (path endsWith: '.sh') | (path endsWith: '.cmd')
]
