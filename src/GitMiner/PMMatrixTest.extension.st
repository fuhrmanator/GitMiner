Extension { #name : #PMMatrixTest }

{ #category : #'*GitMiner' }
PMMatrixTest >> testMatrixDiagonal [
	| a |
	a := PMMatrix rows: #(#(1 2 3) #(4 5 6) #(7 8 9)).
	self assert: a principalDiagonal equals: #(1 5 9) asPMVector.
]
