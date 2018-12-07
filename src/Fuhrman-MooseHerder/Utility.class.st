"
Class with homeless methods... To be refactored into an API.
"
Class {
	#name : #Utility,
	#superclass : #Object,
	#category : #'Fuhrman-MooseHerder'
}

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
