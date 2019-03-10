Extension { #name : #Bag }

{ #category : #'*GitMiner' }
Bag >> intersectionKeepingOccurrences: aSet [
	"return a bag which intersects the set, but keeping the occurrences of the initial bag."
	^ self select: [ :each | aSet anySatisfy: [ :int | int = each ] ].
]
