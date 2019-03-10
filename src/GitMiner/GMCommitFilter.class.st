"
I am a class that tries to help with selecting commits for data mining.
"
Class {
	#name : #GMCommitFilter,
	#superclass : #Object,
	#category : #GitMiner
}

{ #category : #'as yet unclassified' }
GMCommitFilter class >> filterCommitsOnRepository: url withRange: range [
	"generates a list of info about commits according to the queries within this method."

	| revisionNumber nCommits location handle revwalk newerCommit difference addedFiles atLeastOneJavaFile commitDataList projectName |
	"Get project name from URL, accounting for cases where it ends in .git"
	self ensureTmpDirectoryCreation.
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName allButLast: '.git' size ].
	location := ('tmp/tempClonesPharo/' , projectName) asFileReference.

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
		ifFalse: [ revwalk pushRange: range ]
		ifTrue: [ revwalk pushHead ].

	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	newerCommit := nil.
	commitDataList := LinkedList new.

	"Walk through just to count commits"
	nCommits := 0.
	revwalk do: [ :commit | nCommits := nCommits + 1 ]. 

	"Revwalk reset didn't work, so we start over"
	revwalk := LGitRevwalk of: handle.
	range = ''
		ifFalse: [ revwalk pushRange: range ]
		ifTrue: [ revwalk pushHead ].

	revisionNumber := 0.
	[ :job | 
	revwalk
		do: [ :commit | 
			revisionNumber := revisionNumber + 1.
			job
				progress: (revisionNumber / nCommits);
				title: 'Analysing revision ' , commit name.
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
							nCommits - revisionNumber + 1. "Revwalk goes from latest to earliest"
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile.
							(Character space join: difference files)} ].
			newerCommit := commit ] ] asJob run.
	self writeCommitResults: commitDataList to: projectName , '_commits.csv'
]

{ #category : #writing }
GMCommitFilter class >> writeCommitResults: commitDataList to: fileName [
	" Generate a CSV with commit results"

	FileStream
		forceNewFileNamed: fileName
		do: [ :csvStream | 
			"{newerCommit . addedFiles . difference numberOfDeltas . atLeastOneJavaFile . committedFiles}"
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_num' 'Added_files' 'n_commited_files' 'has_java' 'committed_files');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: commitDataList ].
]
