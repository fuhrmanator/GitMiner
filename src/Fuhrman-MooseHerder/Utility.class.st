"
Class with homeless methods... To be refactored into an API.
"
Class {
	#name : #Utility,
	#superclass : #Object,
	#classInstVars : [
		'cloneRoot'
	],
	#category : #'Fuhrman-MooseHerder'
}

{ #category : #'file service' }
Utility class >> applyRenamingsToTransactions: projectsFile [
	"comment stating purpose of message"

	| working projectRecords projectName tempRepoRoot transactionsExtension newTransactionExtension clientImplementationPairsExtension file csvInputStream clientImplementationPairsRecords classesToCheckRenamings perlErrors renameHistoryCSV clientsTemp implementationsTemp perlProgram |
	tempRepoRoot := 'c:/tmp/tempClonesPharo/'.
	transactionsExtension := '_commits_UIDs_transactions.csv'.
	newTransactionExtension := '_commits_UIDs_transactions_renamed.csv'.
	clientImplementationPairsExtension := '_HEAD_ClientImpPairs.csv'.
	renameHistoryCSV := '/tmp/_renamings_temp.csv'.
	perlProgram := '/tmp/hist2renamecsv.perl'.
	perlErrors := '/tmp/_perl_errors'.
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	projectRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	projectRecords
		do: [ :projectRecord | 
			| githubUrl cTransactionsOriginal renamedCTransactions cTransactions |
			githubUrl := projectRecord last.
			githubUrl = 'NA'
				ifFalse: [ projectName := projectRecord second.
					file := (projectName , transactionsExtension) asFileReference.
					cTransactionsOriginal := self loadCommitTransactions: file.
					cTransactions := cTransactionsOriginal copy.
					"Load clients and implementations"
					"Read in CSV of structural coupling (client-implementation)"
					file := (projectName , clientImplementationPairsExtension) asFileReference.
					clientImplementationPairsRecords := self loadClientImplementationPairs: file.
					clientImplementationPairsRecords isNotEmpty 
						ifTrue: [ "Client file name is second column"
							clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
							"Implementation file name is fifth column"
							implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
							classesToCheckRenamings := clientsTemp union: implementationsTemp.
							classesToCheckRenamings
								do: [ :class | 
									| projectRepoDir command result renamings dirs csvPath |
									"Generate git history"
									projectRepoDir := tempRepoRoot , projectName.
									command := 'cd ' , projectRepoDir , ' && git log --follow -p -- "' , class , '" | perl -0777 -n ' , perlProgram , ' > ' , renameHistoryCSV , ' 2>' , perlErrors.
									result := LibC uniqueInstance system: command.
									result = 0
										ifFalse: [ 0 halt ]
										ifTrue: [ "Load CSV of renamed names"
													dirs := renameHistoryCSV splitOn: $/.
													csvPath := FileLocator C.
													dirs
														do: [ :dir | 
															dir = ''
																ifFalse: [ csvPath := csvPath / dir ] ].
													renamings := self loadRenamings: csvPath.

													"For each transaction, replace any instance of a 'from' renaming with the current name"
													renamedCTransactions := OrderedCollection new.
													cTransactions
														do: [ :cTransaction | 
															| copyCTransaction i |
															"make copy of transaction record and add it to the new set"
															copyCTransaction := cTransaction copy.
															renamedCTransactions add: copyCTransaction .
															i := 0.
															cTransaction committedFileNames
																do: [ :classToMaybeRename | 
																	i := i + 1.
																	renamings
																				do: [ :renamingRecord | 
																					| fromRename percent |
																					percent := renamingRecord second.
																					fromRename := renamingRecord fourth.
																					copyCTransaction renameAll: fromRename to: class ] ]  .
													"Update for next class to check for renamings"
													cTransactions := renamedCTransactions ] ] ] ]

					"Check for case of no clients/implementations (no interfaces), just use original records (nothing to rename)"
					ifFalse: [ renamedCTransactions  := cTransactionsOriginal  copy ].

					self writeCommitTransactions: renamedCTransactions to: projectName , newTransactionExtension ] ]
		displayingProgress: [ :projectRecord | 'Applying renamings to project: ' , projectRecord second ]
]

{ #category : #'file service' }
Utility class >> calculateCouplingIntersections [
	| logicalCouplingFiles arulesExtension clientImpExtension basename trimCurlyBraces linkString results |
	arulesExtension := '_renamed_apriori_rules.csv'.
	clientImpExtension := '_HEAD_ClientImpPairs.csv'.
	linkString := '->'.
	trimCurlyBraces := [ :string | string allButFirst allButLast ].
	results := OrderedCollection new.
	logicalCouplingFiles := FileLocator workingDirectory / 'arules'
		allChildrenMatching: '*' , arulesExtension.
	"	Transcript
		show: 'Processing files: ';
		cr.
	Transcript
		show: (' ' join: logicalCouplingFiles);
		cr."
	logicalCouplingFiles
		do: [ :logicalCouplingFile | 
			| clientImpFile lcInputStream lcRecords scRecords logicalCouplingSet protectedCouplingSet unprotectedCouplingSet logicalProtectedIntersection logicalUnprotectedIntersection |
			basename := logicalCouplingFile basename
				allButLast: arulesExtension size.
			clientImpFile := FileLocator workingDirectory
				/ (basename , clientImpExtension).
			"Transcript
				show: basename;
				cr."
			"Read in CSV of logical coupling"
			lcInputStream := logicalCouplingFile readStream.
			lcRecords := (NeoCSVReader on: lcInputStream)
				separator: $,;
				skipHeader;
				"ruleNumber LHS RHS support confidence lift count"
					addIntegerField;
				"ruleNumber"
					addFieldConverter: trimCurlyBraces;
				"{LHS} - note R puts {...} around the string"
					addFieldConverter: trimCurlyBraces;
				"{RHS}"
					addFloatField;
				"support"
					addFloatField;
				"confidence"
					addFloatField;
				"lift"
					addIntegerField;
				"count"
					upToEnd.

			"Read in CSV of structural coupling (client-implementation)"
			scRecords := self loadClientImplementationPairs: clientImpFile.

			"Create a set of logical coupling"
			logicalCouplingSet := (lcRecords
				collect: [ :each | each second , linkString , each third ]) asSet.
			"Transcript
				show: 'Logical coupling set size: ' , logicalCouplingSet size asString;
				cr."
			protectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifTrue: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Protected coupling set size: ' , protectedCouplingSet size asString;
				cr."
			unprotectedCouplingSet := (scRecords
				collect: [ :each | 
					each sixth
						ifFalse: each second , linkString , each fifth ]) asSet.
			"Transcript
				show: 'Unprotected coupling set size: ' , unprotectedCouplingSet size asString;
				cr."
			logicalProtectedIntersection := logicalCouplingSet
				intersection: protectedCouplingSet.
			logicalUnprotectedIntersection := logicalCouplingSet
				intersection: unprotectedCouplingSet.
			"Transcript
				show: 'Intersection of logical coupling and protected coupling set size:' , logicalProtectedIntersection size asString;
				cr."
			"						, (' ' join: logicalProtectedIntersection); cr."
			"Transcript
				show:
					'Intersection of logical coupling and unprotected coupling set size: '
						, logicalUnprotectedIntersection size asString;
				cr."
			"						, (' ' join: logicalUnprotectedIntersection); cr"
			results
				add:
					{basename.
					logicalCouplingSet size.
					protectedCouplingSet size.
					unprotectedCouplingSet size.
					logicalProtectedIntersection size.
					logicalUnprotectedIntersection size} ]
		displayingProgress: [ :file | 'Processing project ' , file basenameWithoutExtension ].
	"Save results to .CSV"
	FileStream
		forceNewFileNamed: 'Logical_and_Structural_Dependency_results.csv'
		do: [ :csvStream | 
			(NeoCSVWriter on: csvStream)
				nextPut:
					#('Project' '|Logical Coupling|' '|Protected Structural Coupling|' '|Unprotected Structural Coupling|' '|Logical Coupling ^ Protected Structural Coupling|' '|Logical Coupling ^ Unprotected Structural Coupling|');
				addFields: #(first second third fourth fifth sixth);
				nextPutAll: results ].
	^ results
]

{ #category : #'as yet unclassified' }
Utility class >> cloneRepo: url [
	"clone a repo of a project (if it doesn't already exist) and return its handle "

	| projectName location |
	"Get project name from URL, accounting for cases where it ends in .git"
	"Clone repo locally if not already there"
	projectName := self extractProjectNameFromURL: url.
	location := (self cloneRoot, projectName) asFileReference.
	location exists
		ifFalse: [ IceGitClone new
				location: location;
				url: url;
				execute ].
	^ location
]

{ #category : #'file service' }
Utility class >> cloneReposAndGenerateCommitMetadata: projectsFile [
	"For all repos in the 'projects.csv' file, make a *_commits.csv file with data regarding the repo"

	| working csvInputStream csvRecords i |
	working := FileSystem disk workingDirectory.
	csvInputStream := (working / projectsFile) readStream.
	csvRecords := self loadProjectsList: csvInputStream.	"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"	"GitHub url"
	i := 0.
	[ :job | 
	csvRecords
		do: [ :each | 
			| githubUrl |
			i := i + 1.
			job
				progress: i / csvRecords size;
				title: 'Generating CSV files for commits: ' , each second.
			githubUrl := each last.
			githubUrl = 'NA'
				ifFalse: [ GitCommitFilter filterCommitsOnRepository: githubUrl withRange: '' ] ] ]
		asJob run
]

{ #category : #accessing }
Utility class >> cloneRoot [
	^ cloneRoot
]

{ #category : #accessing }
Utility class >> cloneRoot: anObject [
	cloneRoot := anObject
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

{ #category : #'as yet unclassified' }
Utility class >> extractProjectNameFromURL: url [
	| projectName |
	projectName := (url splitOn: '/') last.
	(projectName endsWith: '.git')
		ifTrue: [ projectName := projectName allButLast: '.git' size ].
	^ projectName
]

{ #category : #'as yet unclassified' }
Utility class >> filterCommitsOnRepo: location fromTag: fromTag toTag: toTag [
	"selects commits from a range specified by Git tags"

	| repoHandle revwalk newerCommit commitDataList nCommits relativeRevNumber projectName startTag endTag outFile |
	projectName := location path basename.
	repoHandle := LGitRepository on: location.
	repoHandle open.
	"Revwalk goes backwards, so we start at 'to' (latest) and end at 'from' (earliest)"
	startTag := 'tags/' , toTag , '*'.
	endTag := 'tags/' , fromTag , '*'.
	revwalk := self historyRevwalk: repoHandle from: startTag to: endTag.
	newerCommit := nil.
	commitDataList := LinkedList new.

	"Walk through just to count commits for progress bar"
	nCommits := 0.
	revwalk do: [ :commit | nCommits := nCommits + 1 ].

	"Revwalk reset didn't work, so we start over"
	revwalk := self historyRevwalk: repoHandle from: startTag to: endTag.

	"Get commit ids that have:
  - no added files (only changed files)
  - 10 or fewer files
  - at least one .java file."
	relativeRevNumber := 0.
	[ :job | 
	revwalk
		do: [ :commit | 
			| addedFiles difference atLeastOneJavaFile |
			relativeRevNumber := relativeRevNumber + 1.
			job
				progress: relativeRevNumber / nCommits;
				title: 'Analyzing revision ' , commit name.
			newerCommit = nil
				ifFalse: [ difference := newerCommit tree diffTo: commit tree.
					addedFiles := Set new.
					difference files
						do:
							[ :file | newerCommit tree entryByPath: file ifAbsent: [ "Transcript show: 'File not found in newer commit: ', file ; cr." addedFiles add: file ] ].
					atLeastOneJavaFile := difference files anySatisfy: [ :file | file endsWith: '.java' ].
					commitDataList
						add:
							{newerCommit name.
							(nCommits - relativeRevNumber + 1).	"Revwalk goes from latest to earliest"
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile.
							(Character space join: difference files)} ].
			newerCommit := commit ] ] asJob run.
	outFile := projectName , '_' , fromTag , '-' , toTag , '_commits_tags.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^outFile
]

{ #category : #'as yet unclassified' }
Utility class >> filterCommitsOnRepo: location withRange: range [
	"generates a list of info about commits according to the queries within this method."

	| handle revwalk newerCommit commitDataList nCommits revisionNumber projectName outFile |
	projectName := location path basename.
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
			| addedFiles difference atLeastOneJavaFile |
			revisionNumber := revisionNumber + 1.
			job
				progress: revisionNumber / nCommits;
				title: 'Analyzing revision ' , commit name.
			newerCommit = nil
				ifFalse: [ difference := newerCommit tree diffTo: commit tree.
					addedFiles := Set new.
					difference files
						do: [ :file | 
							newerCommit tree
								entryByPath: file
								ifAbsent:
									[ "Transcript show: 'File not found in newer commit: ', file ; cr." addedFiles add: file ] ].
					atLeastOneJavaFile := difference files
						anySatisfy: [ :file | file endsWith: '.java' ].
					commitDataList
						add:
							{newerCommit name.
							(nCommits - revisionNumber + 1).	"Revwalk goes from latest to earliest"
							(Character space join: addedFiles).
							difference numberOfDeltas.
							atLeastOneJavaFile.
							(Character space join: difference files)} ].
			newerCommit := commit ] ] asJob run.
	outFile := projectName , '_commits.csv'.
	self writeCommitResults: commitDataList to: outFile.
	^outFile
]

{ #category : #'file service' }
Utility class >> generateClientImplementationPairs: extension [
	"For every MSE file in the data_mining directory tree, mine the client-implementation pairs info"

	| mseDirRoot mseDirs |
	mseDirRoot := FileLocator C / 'tmp' / 'data_mining'.
	mseDirs := mseDirRoot directories.
	mseDirs
		do: [ :dir | 
			| mseFiles results projectName |
			projectName := dir basename asString allButLast: '_master' size.
			mseFiles := dir allChildrenMatching: '*.mse'.
			mseFiles
				do: [ :mseFile | 
					results := InterfaceMiner mineClientImplementationPairs: mseFile readStream withPrefix: ''.
					"results size = 0 ifTrue: 0halt." "-> no interfaces will yield this"
					"Save results to .CSV"
					FileStream
						forceNewFileNamed: projectName , '_', mseFile basenameWithoutExtension , '_' , 'ClientImpPairs' , '.csv'
						do: [ :csvStream | 
							(NeoCSVWriter on: csvStream)
								nextPut: #('Client' 'ClientFile' 'Interface' 'Implementation' 'ImplementationFile' 'Protected');
								addFields: #(first second third fourth fifth sixth);
								nextPutAll: results ] ] ]
		displayingProgress: [ :dir | 'Processing directory ' , dir fullName , '...' ]
]

{ #category : #'file service' }
Utility class >> generateLogicalCouplingCandidatePairsAndTransactions: fileEnding [
	"take files ending with '_commits_UIDs.csv' and create the logical coupling candidate pairs and transaction files"

	| working selectedCommitFiles |
	working := FileSystem disk workingDirectory.
	selectedCommitFiles := working allChildrenMatching: '*' , fileEnding.
	selectedCommitFiles
		do: [ :file | 
			| csvInputStream csvRecords logicalCouplingRecords project commitTransactions outFileName |
			"Parse the CSV and gather the UIDs for commits that match criteria"
			project := file basename allButLast: fileEnding size.
			csvInputStream := file readStream.
			csvRecords := (NeoCSVReader on: csvInputStream)
				separator: $,;
				skipHeader;
				addField;
				"Commit_id"
					addField;
				"Revision_number"
					addField;
				"committed_files"
					upToEnd.
			logicalCouplingRecords := OrderedCollection new.
			commitTransactions := OrderedCollection new.	"Transaction data: UID, item, item, ..."
			"Write out the logical coupling of java classes for the selected commits"
			"It's pairs of classes in the committed_files set"
			csvRecords
				do: [ :rec | 
					| committedFiles committedClasses classPairs uid revNum |
					uid := rec first.
					revNum := rec second.
					committedFiles := rec third splitOn: Character space.
					committedClasses := committedFiles
						select: [ :each | each endsWith: '.java' ].
					commitTransactions 
						addFirst: (CommitTransaction new uid:uid; committedFileNames: committedClasses). "ID, item, item, ...".
					"Note: this won't create pair-entries for commits with only one java file."
					classPairs := committedClasses combinations
						select: [ :each | each size = 2 ].
					classPairs
						do: [ :pair | 
							| sortedPair |
							sortedPair := pair asSortedCollection.
							"Add the pair twice - logical coupling could be either direction"
							logicalCouplingRecords
								addFirst:
									{project.
									pair first.
									pair second.
									uid.
									revNum}.
							logicalCouplingRecords
								addFirst:
									{project.
									pair second.
									pair first.
									uid.
									revNum} ] ].
			"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
			FileStream
				forceNewFileNamed: file basenameWithoutExtension , '_logicalcoupling.csv'
				do: [ :csvStream | 
					(NeoCSVWriter on: csvStream)
						nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
						addFields: #(first second third fourth fifth);
						nextPutAll: logicalCouplingRecords ].
			"Generates a 'transactions' (basket) style file for arules in R"
			outFileName := file basenameWithoutExtension , '_transactions.csv'.
			self writeCommitTransactions: commitTransactions to: outFileName]
		displayingProgress: [ :file | 
			'Generating data to calculate logical coupling for ' , file basename
				allButLast: fileEnding size ]
]

{ #category : #'file service' }
Utility class >> generateLogicalCouplingPairsWithR: inputPath [
	| command |
	"TODO: Error check to remind user to add RScript.exe to path"
	command := 'RScript R/GenerateLogicalPairsFromTransactions.R ' , inputPath
		, ' 2> /tmp/R.errors.txt'.
	Transcript
		show: 'About to execute: ';
		cr;
		show: command.
	^ LibC uniqueInstance system: command
]

{ #category : #'file service' }
Utility class >> generateMSEFilesForEachHEAD: uidFileSuffix [
	"For each *_UIDs.csv file, generate a Moose MSE for the HEAD of repo"

	| working uidFiles destPath repoPath gitErrors jdt2FamixErrors revPath |
	destPath := '/tmp/data_mining'.
	gitErrors := '/tmp/errors_git'.
	jdt2FamixErrors := '/tmp/errors_jdt2famix'.
	working := FileSystem disk workingDirectory.
	uidFiles := working allChildrenMatching: '*' , uidFileSuffix.

	"Create a new sub dir for the repos MSE dirs"
	(working / 'MSE') ensureCreateDirectory.
	uidFiles
		do: [ :file | 
			| repoName uidFileName uid command result |
			"Create a new sub dir for the repos MSE files"
			uidFileName := file basename.
			repoName := uidFileName allButLast: uidFileSuffix size.
			repoPath := '/tmp/tempClonesPharo/' , repoName.
			uid := 'HEAD'.
			revPath := destPath , '/' , repoName , '_master/' , uid.
			command := 'cd ' , repoPath , ' && git --work-tree=' , revPath , ' checkout ' , uid
				, ' -- . 2>' , gitErrors.
			revPath asFileReference ensureCreateDirectory.
			"self logCr: 'About to create directory: ', revPath ."
			OSEnvironment current setEnv: 'GIT_INDEX_FILE' value: revPath , '/.git'.
			result := LibC uniqueInstance system: command.
			"self logCr: 'About to execute command: ', command. result := 0."
			result = 0
				ifFalse: [ gitErrors asFileReference ]
				ifTrue: [ | mseFile mseDestination |
					"Make an MSE file"
					command := 'cd ' , revPath , ' && /jdt2famix-bin-1.0.12/jdt2famix.cmd 2>'
						, jdt2FamixErrors.
					result := LibC uniqueInstance system: command.
					"self logCr: 'About to execute command: ', command. result := 0."
					result = 0
						ifFalse: [ jdt2FamixErrors asFileReference ]
						ifTrue: [ "Move the file out of the directory"
							mseFile := (revPath , '/' , uid , '.mse') asFileReference.
							mseDestination := (destPath , '/' , repoName , '_master/' , uid , '.mse')
								asFileReference.
							"self logCr: 'About to move ', mseFile asString, ' to ', mseDestination asString."
							mseFile exists
								ifTrue: [ mseDestination exists
										ifTrue: [ mseDestination delete ].
									mseFile moveTo: mseDestination ] ].
					"Clean up the directories and files"
					revPath asFileReference deleteAll ] ]
		displayingProgress: [ :file | 'Generating MSE file for HEAD of: ' , file basename ]
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
Utility class >> generatePairsAndTransactions: selectedCommitsFile suffix: fileEnding [
	"Create the logical coupling candidate pairs and transaction file from the set of selected commits"
			| csvInputStream csvRecords logicalCouplingRecords project commitTransactions outFileName |
			"Parse the CSV and gather the UIDs for commits that match criteria"
			project := selectedCommitsFile basename allButLast: fileEnding size.
			csvInputStream := selectedCommitsFile readStream.
			csvRecords := (NeoCSVReader on: csvInputStream)
				separator: $,;
				skipHeader;
				addField;
				"Commit_id"
					addField;
				"Revision_number"
					addField;
				"committed_files"
					upToEnd.
			logicalCouplingRecords := OrderedCollection new.
			commitTransactions := OrderedCollection new.	"Transaction data: UID, item, item, ..."
			"Write out the logical coupling of java classes for the selected commits"
			"It's pairs of classes in the committed_files set"
			csvRecords
				do: [ :rec | 
					| committedFiles committedClasses classPairs uid revNum |
					uid := rec first.
					revNum := rec second.
					committedFiles := rec third splitOn: Character space.
					committedClasses := committedFiles
						select: [ :each | each endsWith: '.java' ].
					commitTransactions 
						addFirst: (CommitTransaction new uid:uid; committedFileNames: committedClasses). "ID, item, item, ...".
					"Note: this won't create pair-entries for commits with only one java file."
					classPairs := committedClasses combinations
						select: [ :each | each size = 2 ].
					classPairs
						do: [ :pair | 
							| sortedPair |
							sortedPair := pair asSortedCollection.
							"Add the pair twice - logical coupling could be either direction"
							logicalCouplingRecords
								addFirst:
									{project.
									pair first.
									pair second.
									uid.
									revNum}.
							logicalCouplingRecords
								addFirst:
									{project.
									pair second.
									pair first.
									uid.
									revNum} ] ].
			"self crLog: 'Creating file ', (file basenameWithoutExtension) , '_logicalcoupling.csv'."
			FileStream
				forceNewFileNamed: selectedCommitsFile basenameWithoutExtension , '_LC.csv'
				do: [ :csvStream | 
					(NeoCSVWriter on: csvStream)
						nextPut: #('Project' 'Class_1' 'Class_2' 'Commit_ID' 'Revision_number');
						addFields: #(first second third fourth fifth);
						nextPutAll: logicalCouplingRecords ].
			"Generates a 'transactions' (basket) style file for arules in R"
			outFileName := selectedCommitsFile basenameWithoutExtension , '_TR.csv'.
			self writeCommitTransactions: commitTransactions to: outFileName
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

{ #category : #'as yet unclassified' }
Utility class >> historyRevwalk: repo from: startTag to: endTag [
	"inits an LGitRevwalk for history between two tags, formatted as 'tags/blah*' where 'blah' is the tag name"
	| revwalk |
	revwalk := LGitRevwalk of: repo.
	revwalk beSortedByCommitTime.
	revwalk beSortedParentsBeforeChildren.
	revwalk pushGlob: startTag.
	revwalk hideGlob: endTag.
	^ revwalk

]

{ #category : #initialization }
Utility class >> initialize [
	"init the variables used in mining"

	cloneRoot := 'c:/tmp/tempClonesPharo/'.
]

{ #category : #'file service' }
Utility class >> loadClientImplementationPairs: fileReference [
	| scRecords scInputStream |
	scInputStream := fileReference  readStream.
	scRecords := (NeoCSVReader on: scInputStream)
		separator: $,;
		skipHeader;
		"Client ClientFile Interface Implementation ImplementationFile Protected"
			addField;
		"Client (Moose name)"
			addField;
		"ClientFile (file name)"
			addField;
		"Interface"
			addField;
		"Implementation (Moose name)"
			addField;
		"ImplementationFile (file name)"
			addFieldConverter: [ :string | string = 'true' ];
		"Protected"
			upToEnd.
	^ scRecords
]

{ #category : #'file service' }
Utility class >> loadCommitTransactions: transactionsFileReference [
	"Load commit transactions. Note NeoCSVReader doesn't support variable records, so we declare spots for many entries, and remove them after."

	| transactionRecords transactions csvInputStream |
	csvInputStream := transactionsFileReference  readStream.
	transactionRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		"Commit UID"
			addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		addField;
		upToEnd.

	"Get rid of the nil elements in the transactions"
	^ transactionRecords 
		collect: [ :transaction | 
			CommitTransaction transactionFromRecord:  (transaction asCollection select: #isNotNil) ]
]

{ #category : #'file service' }
Utility class >> loadProjectsList: csvInputStream [
	| csvRecords |
	csvRecords := (NeoCSVReader on: csvInputStream)
		separator: $,;
		skipHeader;
		"ID	Project	Str.Dep.	Log.Dep.	Int.Set	CSD(%)	CLD(%)	GC_url	GitHub_url"
			addIntegerField;
		addField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addIntegerField;
		addField;
		addField;
		"GitHub url"
			upToEnd.
	^ csvRecords
]

{ #category : #'file service' }
Utility class >> loadRenamings: csvPath [
 	"Load csv file of renamings (from git history)"
	| records |
	records := (NeoCSVReader on: csvPath readStream)
		separator: $,;
		"UID"
		addField;
		"percentage"
		addIntegerField; 
		"operation (copy or rename)"
		addField;
		"from name"
		addField;
		"to name"
		addField;		
		upToEnd.
		^ records
]

{ #category : #'file service' }
Utility class >> removeUnrelatedClassesFromTransactions: project [
	"Go through renamed transaction files and remove the class names that aren't clients or implementations"
	 | cTransactions file clientImplementationPairsRecords clientsTemp implementationsTemp classesToInclude | 
	file := (project,'_commits_UIDs_transactions_renamed.csv') asFileReference .
	cTransactions := self loadCommitTransactions:  file.
	file := (project, '_HEAD_ClientImpPairs.csv') asFileReference .
	clientImplementationPairsRecords := self loadClientImplementationPairs: file.
	clientImplementationPairsRecords size > 0
	ifTrue: [ "Client file name is second column"
		clientsTemp := (clientImplementationPairsRecords collect: #second) asSet.
		"Implementation file name is fifth column"
		implementationsTemp := (clientImplementationPairsRecords collect: #fifth) asSet.
		classesToInclude := clientsTemp union: implementationsTemp.
		cTransactions do: [ :cTran |
			cTran committedFileNames: (cTran committedFileNames intersection: classesToInclude )
			 ]
		].
	self writeCommitTransactions: cTransactions  to: project,'_commits_UIDs_transactions_renamed_only_clients_and_imps.csv'.	
	^cTransactions
]

{ #category : #writing }
Utility class >> writeCommitResults: commitDataList to: fileName [
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

{ #category : #writing }
Utility class >> writeCommitTransactions: transactionRecords to: outFileName [
	"Write out single column (with embedded commas!)"
	| concatRecords |
	"Concatenate variable number of items with commas, since we can't use NeoCSV to write them"
	concatRecords := OrderedCollection new.
	transactionRecords 
		ifNotNil: [ transactionRecords  do: [ :cTran | concatRecords add: (cTran uid, ',', ($, join: cTran committedFileNames ))	"ID, item, item, ..." ] ].
	^ FileStream
		forceNewFileNamed: outFileName
		do: [ :stream | 
			concatRecords
				do: [ :rec |
					stream
						"data is text, not binary"
						ascii;
							nextPutAll: rec;
						cr ] ]
]
