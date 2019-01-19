"
Followed instructions from https://github.com/pharo-open-documentation/pharo-wiki Baselines
"
Class {
	#name : #BaselineOfGitMiner,
	#superclass : #BaselineOf,
	#category : #BaselineOfGitMiner
}

{ #category : #baselines }
BaselineOfGitMiner >> baseline: spec [
	<baseline>
	spec for: #common do: [ 
		"spec baseline: 'Moose' with: [ 
			spec repository: 'github://moosetechnology/Moose:development/src' ]."

      spec postLoadDoIt: #launchVerifications.
		"Packages" 
		spec 
		  package: 'GitMiner'.
		 ]
]

{ #category : #baselines }
BaselineOfGitMiner >> launchVerifications [
	"Todo: make sure RScript is in the path?"

	self class environment
		at: #GMUtility
		ifPresent: [ :utilClass | 
			utilClass isRInPath
				ifFalse: [ UIManager default
						abort:
							'RScript.exe could not be found. R must be installed and RScript.exe''s directory must be added to the system path' ] ]
]
