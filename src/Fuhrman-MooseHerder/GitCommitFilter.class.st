Class {
	#name : #GitCommitFilter,
	#superclass : #Object,
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #'as yet unclassified' }
GitCommitFilter class >> filterCommitsOnRepository: url withRange: range [
	"generates a list of info about commits according to the queries within this method."

	| location handle revwalk newerCommit difference addedFiles atLeastOneJavaFile commitDataList projectName |
	"Get project name from URL, accounting for cases where it ends in .git"
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName copyFrom: 1 to: projectName size - '.git' size - 1 ].
	location := ('c:/tmp/tempClonesPharo/' , projectName) asFileReference.

	"Clone repo locally if not already there"
	location exists
		ifFalse: [ IceGitClone new
				location: location;
				url: url;
				execute ].
	handle := LGitRepository on: location.
	handle open.
	revwalk := LGitRevwalk of: handle.
	range = ''
		ifFalse: [revwalk pushRange: range]
		ifTrue: [revwalk pushHead].

	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	newerCommit := nil.
	commitDataList := LinkedList new.
	revwalk
		do: [ :commit | 
			newerCommit = nil
				ifFalse: [ difference := newerCommit tree diffTo: commit tree.
					addedFiles := Set new.
					difference files
						do: [ :file | 
							newerCommit tree
								entryByPath: file
								ifAbsent: [ "Transcript show: 'File not found in newer commit: ', file ; cr." addedFiles add: file ] ].
					atLeastOneJavaFile := difference files anySatisfy: [ :file | file endsWith: '.java' ].
					commitDataList
						add:
							{newerCommit name.
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile} ].
			newerCommit := commit ].
	self writeCommitResults: commitDataList to: projectName , '.csv'
]

{ #category : #writing }
GitCommitFilter class >> writeCommitResults: commitDataList to: fileName [
	" Generate a CSV with commit results"

	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			"{newerCommit . addedFiles . difference numberOfDeltas . atLeastOneJavaFile}"
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Added_files' 'n_commited_files' 'has_java');
				addFields: #(first second third fourth);
				nextPutAll: commitDataList ]
]
