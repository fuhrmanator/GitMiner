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
		spec baseline: 'NeoCSV' with: [ spec repository: 'github://svenvc/NeoCSV/repository' ].

		spec preLoadDoIt: #verifyMooseInstalled.
      spec postLoadDoIt: #launchVerifications.
		"Packages" 
		spec 
		  package: 'GitMiner'.
		 ]
]

{ #category : #baselines }
BaselineOfGitMiner >> launchVerifications [
	"Make sure RScript is in the path?"

	self class environment
		at: #GMUtility
		ifPresent: [ :utilClass | 
			utilClass isRInPath
				ifFalse: [ UIManager default
						abort:
							'RScript.exe could not be found. R must be installed and RScript.exe''s directory must be added to the system path' ] ]
]

{ #category : #baselines }
BaselineOfGitMiner >> verifyMooseInstalled [
	self class environment
		at: #MooseModel
		ifAbsent: [ UIManager default
						abort:
							'Moose must be installed prior to loading GitMiner. The baseline doesn''t load it because it''s big. We recommend loading it from the GitHub repo, or starting with a Moose image from Pharo Launcher.' ]
]
