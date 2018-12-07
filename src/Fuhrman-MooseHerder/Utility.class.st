"
Class with homeless methods... To be refactored into an API.
"
Class {
	#name : #Utility,
	#superclass : #Object,
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #'file service' }
Utility class >> cloneReposAndGenerateCommitMetadata: projectsFile [ 
"For all repos in the 'projects.csv' file, make a *_commits.csv file with data regarding the repo"

| working csvInputStream csvRecords i |

working := FileSystem disk workingDirectory.
csvInputStream := (working / projectsFile) readStream.
csvRecords := (NeoCSVReader on:  csvInputStream) 
   separator: $,;
   skipHeader; "ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"
   addIntegerField;
   addField;
   addIntegerField;
   addIntegerField;
   addIntegerField;
   addIntegerField;
   addIntegerField;
   addField; 
   addField; "GitHub url"
   upToEnd.


i := 0.
[:job |
		csvRecords do: [:each | 
			| githubUrl |
			i := i + 1.
			job 
				progress: i / (csvRecords size);
				title: 'Generating CSV files for commits: ', each second.
			githubUrl := each last.
			githubUrl = 'NA' 
				ifFalse: [ GitCommitFilter filterCommitsOnRepository: githubUrl withRange: '' ] .
		]
] asJob run.
]

{ #category : #'file service' }
Utility class >> extractIndividualProjectLogicalCouplingData: csvFile [
	"take a big CSV file and break it into smaller ones, project by project"

	| project csvWriter csvOutStream count |
	project := ''.
	csvWriter := nil.
	csvOutStream := nil.
	count := 0.
	[ :job | 
	csvFile asFileReference
		readStreamDo: [ :input | 
			(NeoCSVReader on: (ZnBufferedReadStream on: input))
				skipHeader;
				"Project	  From Class	  To Class	  Revision ID"
					addField;
				"Project"
					"NeoCSV grabs spaces between the ',' separators"
					addFieldConverter: [ :string | string trimBoth ];
				"From Class"
					addFieldConverter: [ :string | string trimBoth ];
				"To Class"
					addFieldConverter: [ :string | string trimBoth asInteger ];
				"Revision ID"
					do: [ :each | 
					each first = project
						ifFalse: [ project := each first.
							count := count + 1.
							"self logCr: 'Found new project: ', project."
							job
								progress: count / 80;
								"80 projects"
									title: 'Extracting data for ' , project asString.
							"init new csv file"
							csvOutStream := FileStream
								forceNewFileNamed: project , '_logicalcoupling_AS2017.csv'.
							csvWriter := NeoCSVWriter on: csvOutStream.
							csvWriter
								nextPut: #('Project' 'From class' 'To class' 'Revision ID');
								addFields: #(first second third fourth) ].
					csvWriter nextPut: each ]
			"			separator: $,;" ] ] asJob run
]

{ #category : #'file service' }
Utility class >> generateLogicalCouplingCandidatePairsAndTransactions: fileEnding [
	"take files ending with '_commits_UIDs.csv' and create the logical coupling candidate pairs and transaction files"

	| working selectedCommitFiles |
working := FileSystem disk workingDirectory. 
selectedCommitFiles := working allChildrenMatching: ('*', fileEnding).

selectedCommitFiles do: [ :file | 
	| csvInputStream csvRecords logicalCouplingRecords project transactionRecords | 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	project := file basename allButLast: fileEnding size.
	csvInputStream := file readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "committed_files"
		upToEnd.

	logicalCouplingRecords := OrderedCollection new.
	transactionRecords := OrderedCollection new. "Transaction data: ID, item, item, ..."
	"Write out the logical coupling of java classes for the selected commits"
	"It's pairs of classes in the committed_files set"
	csvRecords do: [ :rec | | committedFiles committedClasses classPairs uid revNum |
		uid := rec first.
		revNum := rec second.
		committedFiles := rec third splitOn: Character space. 
		committedClasses := committedFiles select: [ :each | each endsWith: '.java' ].
		transactionRecords addFirst: uid , ',' , ($, join: committedClasses). "ID, item, item, ..."
		"Note: this won't create entries for commits with only one java file."
		classPairs := committedClasses combinations select: [ :each | each size = 2 ].
		classPairs do: [ :pair | | sortedPair |
			sortedPair := pair asSortedCollection.
			"Add the pair twice - logical coupling could be either direction"
			logicalCouplingRecords addFirst: { project . pair first . pair second . uid . revNum }.
			logicalCouplingRecords addFirst: { project . pair second . pair first . uid . revNum }
			 ]
	].
	"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
	FileStream
		forceNewFileNamed: (file basenameWithoutExtension) , '_logicalcoupling.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
				addFields: #(first second third fourth fifth);
				nextPutAll: logicalCouplingRecords  ].
	"Generates a 'transactions' (basket) style file for arules in R"
	FileStream
		forceNewFileNamed: (file basenameWithoutExtension) , '_transactions.csv'
		do: [ :stream |
         transactionRecords do: [ :rec |
             stream
                 ascii; "data is text, not binary"
                 nextPutAll: rec;
                 cr ] ].

] displayingProgress: [ :file | 'Generating data to calculate logical coupling for ', file basename allButLast: fileEnding size ]

]

{ #category : #'file service' }
Utility class >> generateLogicalCouplingPairsWithR: inputPath [ 
	^ LibC uniqueInstance system: '"c:\Program Files\R\R-3.5.1\bin\RScript.exe" c:\chgevo\R\GenerateLogicalPairsFromTransactions.R ', inputPath, ' 2> /tmp/R.errors.txt'.
]

{ #category : #'file service' }
Utility class >> generateMSEFilesForEachUID: uidFileSuffix [
"For each *_UIDs.csv file, generate a Moose MSE "

| working uidFiles destPath repoPath gitErrors jdt2FamixErrors revPath |
destPath := '/tmp/data_mining'.
gitErrors := '/tmp/errors_git'.
jdt2FamixErrors := '/tmp/errors_jdt2famix'.


working := FileSystem disk workingDirectory.
"uidFileSuffix := '_commits_UIDs.csv'."
uidFiles := working allChildrenMatching: ('*', uidFileSuffix) .

"Create a new sub dir for the repos MSE dirs"
(working / 'MSE') ensureCreateDirectory.

uidFiles do: [ :file | 
	| csvInputStream csvRecords selectedCommits repoName uidFileName | 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	csvInputStream := file readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "Committed_files"
		upToEnd.
	
	"Create a new sub dir for the repos MSE files"
	uidFileName := file basename.
	repoName := uidFileName allButLast: uidFileSuffix size.
   repoPath := '/tmp/tempClonesPharo/', repoName.	 

	csvRecords do: [ :csvRecord |
		| uid command result |
		uid := csvRecord first.
		revPath := destPath, '/',  repoName, '_master/', uid.
		command := 'cd ', repoPath, ' && git --work-tree=', revPath, ' checkout ', uid, ' -- . 2>', gitErrors.
		(revPath asFileReference ) ensureCreateDirectory.
		"self logCr: 'About to create directory: ', revPath ." 
		OSEnvironment current setEnv: 'GIT_INDEX_FILE' value: (revPath, '/.git').
		result := LibC uniqueInstance system: command.
		"self logCr: 'About to execute command: ', command. result := 0."

		result = 0 ifFalse: [ gitErrors asFileReference  ]
		ifTrue: [ 
			| mseFile mseDestination |
			"Make an MSE file"
			command := 'cd ', revPath, ' && /jdt2famix-bin-1.0.12/jdt2famix.cmd 2>', jdt2FamixErrors.
			result := LibC uniqueInstance system: command.
			"self logCr: 'About to execute command: ', command. result := 0." 
			result = 0 ifFalse: [ jdt2FamixErrors asFileReference ]
			ifTrue: [ 	
				"Move the file out of the directory"
				mseFile := (revPath, '/', uid, '.mse') asFileReference.
				mseDestination := (destPath , '/', repoName, '_master/', uid, '.mse' ) asFileReference.
				"self logCr: 'About to move ', mseFile asString, ' to ', mseDestination asString."
				mseFile exists ifTrue: [ 
					mseDestination exists ifTrue: [ mseDestination delete ].
					mseFile moveTo: mseDestination ]
			].
			"Clean up the directories and files"
			revPath asFileReference deleteAll.
		]
		
	] displayingProgress: [ :r | 'Processing UID: ', r first ].
	
] displayingProgress: [ :file | 'Processing: ', file basename  ].


]

{ #category : #'file service' }
Utility class >> generateSelectedCommitFiles: commitFileExtension [
"Selects commits from *_commits.csv files and writes out a list of UIDs that match (in a *_UIDs.csv file)"

| working commitFiles |
working := FileSystem disk workingDirectory.

"working := 'G:\My Drive\Congé sabbatique 2018-2019\Activités INRIA\Change Evolution Interface Clients\Pharo image' asFileReference."

commitFiles := working allChildrenMatching: commitFileExtension.

commitFiles do: [ :file | 
	| csvInputStream csvRecords selectedCommits commitID revisionNumber addedFiles countCommittedFiles hasJava committedFiles |
 
	"Parse the CSV and gather the UIDs for commits that match criteria"
	csvInputStream := file readStream.
	csvRecords := (NeoCSVReader on:  csvInputStream) 
		separator: $,;
		skipHeader;
		addField; "Commit_id"
		addField; "Revision_number"
		addField; "set of Added_files"
		addIntegerField; "n_committed_files"
		addField; "has_java"
		addField; "committed_files"
		upToEnd.

	"Transcript show: csvRecords; cr."

	selectedCommits := csvRecords select: [ :each | 
"		commitID := each first. 
		revisionNumber := each second. "
		addedFiles := each third. 
		countCommittedFiles := each fourth. 
		hasJava := each fifth. 
"		committedFiles := each sixth." 
		(addedFiles = nil "no added files") and: (countCommittedFiles <= 10 and: hasJava = 'true')].

	"Write out the list of UIDs for the selected commits"
	"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_UIDs.csv'."
	FileStream
		forceNewFileNamed: (file basenameWithoutExtension) , '_UIDs.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut: #('Commit_id' 'Revision_number' 'committed_files');
				addFields: #(first second sixth);
				nextPutAll: selectedCommits ].
] displayingProgress: [ :file | 'Selecting UIDs in: ', file basename ]
]
