Class {
	#name : #GMUtilityTest,
	#superclass : #TestCase,
	#category : #'GitMiner-Tests'
}

{ #category : #tests }
GMUtilityTest >> testShortOID [
	self assert: (GMUtility shortOID: '342abc3344aebcd') equals: '342abc3'.
	self assert: (GMUtility shortOID: '342abc') equals: '342abc'.
]
