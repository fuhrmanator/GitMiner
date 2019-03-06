Class {
	#name : #GMBagTest,
	#superclass : #TestCase,
	#category : #GitMiner
}

{ #category : #tests }
GMBagTest >> testIntersectionKeepingCounts [
	| b1 b2 s1 |
	b1 := #(#red #blue #blue #green) asBag.
	s1 := #(#red #blue #yellow) asSet.
	b2 := b1 intersectionKeepingCounts: s1.
	self assert: b2 equals: #(#red #blue #blue) asBag
]
