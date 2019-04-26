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
	spec
		for: #common
		do:
			[ "Don't load Moose finally, it's heavy. Recommend users to start with CI image."
			spec
				baseline: 'NeoJSON'
					with: [ spec repository: 'github://svenvc/NeoJSON/repository' ];
				baseline: 'NeoCSV'
					with: [ spec repository: 'github://svenvc/NeoCSV/repository' ];
				baseline: 'PolyMath'
					with: [ spec repository: 'github://PolyMathOrg/PolyMath:master/src' ].
			spec preLoadDoIt: #verifyMooseInstalled.
			spec postLoadDoIt: #launchVerifications.
			"Packages"
			spec
				package: 'GitMiner' with: [ spec requires: #('NeoJSON') ];
				package: 'GitMiner' with: [ spec requires: #('NeoCSV') ];
				package: 'GitMiner' with: [ spec requires: #('PolyMath') ];
				package: 'GitMiner-Tests' with: [ spec requires: #('GitMiner') ] ]
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
