Class {
	#name : #GMBagTest,
	#superclass : #TestCase,
	#category : #GitMiner
}

{ #category : #tests }
GMBagTest >> testIntersectionKeepingOccurrences [
	| b1 b2 s1 |
	b1 := #(#red #blue #blue #green) asBag.
	s1 := #(#red #blue #yellow) asSet.
	b2 := b1 intersectionKeepingOccurrences: s1.
	self assert: b2 equals: #(#red #blue #blue) asBag.
	
	b1 := #(#red #red #blue #blue #green) asBag.
	s1 := #(#red #blue #yellow) asSet.
	b2 := b1 intersectionKeepingOccurrences: s1.
	self assert: b2 equals: #(#red #red #blue #blue) asBag.
	
	b1 := #(#green) asBag.
	s1 := #(#red #blue #yellow) asSet.
	b2 := b1 intersectionKeepingOccurrences: s1.
	self assert: b2 equals: #() asBag.
	
	b1 := #(#green) asBag.
	s1 := #(#green) asSet.
	b2 := b1 intersectionKeepingOccurrences: s1.
	self assert: b2 equals: #(#green) asBag.
]
