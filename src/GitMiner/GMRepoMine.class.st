"
I represent a mining operation on a git repository.

I encapsulate information about a mining operation. I know how to filter commits by time, tags, OIDs and allow other filters.

My main collaborators are LGit* classes.

---- TODO

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	commitFilter:		<Object>
	fromTag:		<Object>
	pathToRepo:		<Object>
	toTag:		<Object>


    Implementation Points
"
Class {
	#name : #GMRepoMine,
	#superclass : #Object,
	#instVars : [
		'pathToRepo',
		'fromTag',
		'toTag',
		'commitFilter'
	],
	#category : #GitMiner
}

{ #category : #accessing }
GMRepoMine >> commitFilter [
	^ commitFilter
]

{ #category : #accessing }
GMRepoMine >> commitFilter: anObject [
	commitFilter := anObject
]

{ #category : #accessing }
GMRepoMine >> fromTag [
	^ fromTag
]

{ #category : #accessing }
GMRepoMine >> fromTag: anObject [
	fromTag := anObject
]

{ #category : #accessing }
GMRepoMine >> pathToRepo [
	^ pathToRepo
]

{ #category : #accessing }
GMRepoMine >> pathToRepo: anObject [
	pathToRepo := anObject
]

{ #category : #accessing }
GMRepoMine >> toTag [
	^ toTag
]

{ #category : #accessing }
GMRepoMine >> toTag: anObject [
	toTag := anObject
]
