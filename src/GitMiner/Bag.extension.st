Extension { #name : #Bag }

{ #category : #'*GitMiner' }
Bag >> intersectionKeepingCounts: aSet [
	"return a bag which intersects the set, but keeping the occurrences of the initial bag."
	| intersectedBag |
	intersectedBag := Bag new.
	self
		doWithOccurrences: [ :element :occurrence | 
			(aSet includes: element)
				ifTrue: [ intersectedBag add: element withOccurrences: occurrence ] ].
	^ intersectedBag
]
