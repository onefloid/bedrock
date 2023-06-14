﻿601,100
602,"}bedrock.hier.import"
562,"CHARACTERDELIMITED"
586,"D:\TM1Models\Bedrock.v4\Log\Currency Currency 2_Export.csv"
585,"D:\TM1Models\Bedrock.v4\Log\Currency Currency 2_Export.csv"
564,
565,"byyk_bB`c3_N[zVYJz^Ci;MtK:nG7evJj6bGrlLQBFyy3}WO7b@xy`W@Y?SQKcb1AB4oWXtA=_lOZH4^V9mqtM@Pza{:pvmd7x>m4fi4zk0ZyzB>_xCC]omV3QPTEde`qZo4<?4\QhO~6O8puh7=Sn0jWIYyXH6R9dc0XDGHDv%O_=d7Eb]aXU;sMpCG4blyxTNUY>"
559,1
928,0
593,
594,
595,
597,
598,
596,
800,
801,
566,0
567,","
588,"."
589,","
568,""""
570,
571,
569,0
592,0
599,1000
560,11
pLogOutput
pStrictErrorHandling
pDim
pHier
pSrcDir
pSrcFile
pDelim
pQuote
pLegacy
pUnwind
pConsol
561,11
1
1
2
2
2
2
2
2
1
1
2
590,11
pLogOutput,0
pStrictErrorHandling,0
pDim,""
pHier,""
pSrcDir,""
pSrcFile,""
pDelim,","
pQuote,""""
pLegacy,0
pUnwind,1
pConsol,"*"
637,11
pLogOutput,"OPTIONAL: Write parameters and action summary to server message log (Boolean True = 1)"
pStrictErrorHandling,"OPTIONAL: On encountering any error, exit with major error status by ProcessQuit after writing to the server message log (Boolean True = 1)"
pDim,"REQUIRED: Dimension"
pHier,"OPTIONAL: Target Hierarchy (defaults to dimension name if blank)"
pSrcDir,"OPTIONAL: Source Directory Path (defaults to Error File Directory)"
pSrcFile,"OPTIONAL: Source File Name (defaults to 'Dimension Hierarchy _Export.csv' if blank)"
pDelim,"OPTIONAL: AsciiOutput delimiter character (Default=comma, exactly 3 digits = ASCII code)"
pQuote,"OPTIONAL: AsciiOutput quote character (Accepts empty quote, exactly 3 digits = ASCII code)"
pLegacy,"OPTIONAL: 1 = Legacy format (bedrock v3) 0 or empty = new bedrock v4 format"
pUnwind,"OPTIONAL: 1 = unwind elements 0 = like for like copy which may result in lost elements / data (2= no clear or unwind, only add)"
pConsol,"OPTIONAL: Target Consolidation, accepts wildcards ( * will unwind ALL). Note: ignored if pUnwind=0"
577,6
V1
V2
V3
V4
V5
V6
578,6
2
2
2
2
2
2
579,6
1
2
3
4
5
6
580,6
0
0
0
0
0
0
581,6
0
0
0
0
0
0
582,6
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
VarType=32ColType=827
603,0
572,280
#Region CallThisProcess
# A snippet of code provided as an example how to call this process should the developer be working on a system without access to an editor with auto-complete.
If( 1 = 0 );
ExecuteProcess( '}bedrock.hier.import', 'pLogOutput', pLogOutput
    , 'pStrictErrorHandling', pStrictErrorHandling
    , 'pDim', '', 'pHier', ''
    , 'pSrcDir', '', 'pSrcFile', ''
    , 'pDelim', ',', 'pQuote', '"'
    , 'pLegacy', 0, 'pUnwind' , 1, 'pConsol', '*'
);
EndIf;
#EndRegion CallThisProcess

#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

#Region @DOC
# Description:
# This process will import Dimension elements into a specified Hierarchy from a File. The process
# is able to read a file generated by `}bedrock.hier.export`.
# __Format of the file:__  
# - 1st line: File metadata contains summary information about the dimension, hierarchy, number of
#   elements and date/time when file was generated.
# - 2nd line: Source dimension and hierarchy.
# - 3rd line: Dimension sort order.
# - 4th and 5th line: Reserved for future development.
# - 6th line: Header for elements export.
# - 7th line and forth: Elements export data.

# Use case:
# 1. Restore a dimension from a backup.
# 2. Quick replication of a large dimension.

# Note:
# Valid dimension name (pDim) is mandatory otherwise the process will abort.
# If needed, custom delimiter might be used by specifying parameter pDelim value as either exactly one
# character or as a 3-digit (decimal) ASCII code. For example to use TAB as a delimiter, use 009.
# pUnwind provides the option to 1 (unwind) or 0 (delete) elements in the target dimension. Default is to unwind,
# care should be taken when using option 0 otherwise data loss may occur.

# Caution: Process was redesigned in Bedrock4 but is able to process dimension extracts from prior
# versions of Bedrock in legacy mode (pLegacy = 1).
#EndRegion @DOC

# This process will Create Dimension hierarchy from File.
### Global Variables
StringGlobalVariable('sProcessReturnCode');
NumericGlobalVariable('nProcessReturnCode');
nProcessReturnCode= 0;

### Constants ###
cThisProcName   = GetProcessName();
cUserName       = TM1User();
cTimeStamp      = TimSt( Now, '\Y\m\d\h\i\s' );
cRandomInt      = NumberToString( INT( RAND( ) * 1000 ));
cTempSub        = cThisProcName |'_'| cTimeStamp |'_'| cRandomInt;
cMsgErrorLevel  = 'ERROR';
cMsgErrorContent= 'Process:%cThisProcName% ErrorMsg:%sMessage%';
cLogInfo        = 'Process:%cThisProcName% run with parameters pDim:%pDim%, pHier:%pHier%, pSrcDir:%pSrcDir%, pSrcFile:%pSrcFile%, pDelim:%pDelim%, pQuote:%pQuote%, pLegacy:%pLegacy%, pUnwind:%pUnwind%, pConsol:%pConsol%';
cLenASCIICode = 3;

pDelim  = TRIM(pDelim);

## LogOutput parameters
IF( pLogoutput = 1 );
    LogOutput('INFO', Expand( cLogInfo ) );   
ENDIF;

nMetaCount = 0;
nDataCount = 0;

### Validate Parameters ###
nErrors = 0;

If( Scan( ':', pDim ) > 0 & pHier @= '' );
    # A hierarchy has been passed as dimension. Handle the input error by splitting dim:hier into dimension & hierarchy
    pHier       = SubSt( pDim, Scan( ':', pDim ) + 1, Long( pDim ) );
    pDim        = SubSt( pDim, 1, Scan( ':', pDim ) - 1 );
EndIf;

# Validate dimension
If( Trim( pDim ) @= '' );
    nErrors = 1;
    sMessage = 'No dimension specified.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
ElseIf( DimensionExists( pDim ) = 0 );
    sMessage = 'Dimension: ' | pDim | ' does not exist and will be created.';
    LogOutput( 'INFO', Expand( cMsgErrorContent ) );
EndIf;

# Validate Hierarchy
sHier       = Trim( pHier );
If( sHier @= '' );
    sHier     = pDim;
ElseIf( sHier @= 'Leaves' );
    If( pUnwind = 1 );
        pUnwind = 2;
        sMessage  = Expand('%cThisProcName%: Leaves hierarchy, unwind is redundant. Changing unwind mode for %pDim%:%pHier% to 2.');
        LogOutput( 'INFO', sMessage );
    EndIf;
EndIf;

## check operating system
If( SubSt( GetProcessErrorFileDirectory, 2, 1 ) @= ':' );
  sOS = 'Windows';
  sOSDelim = '\';
ElseIf( Scan( '/', GetProcessErrorFileDirectory ) > 0 );
  sOS = 'Linux';
  sOSDelim = '/';
Else;
  sOS = 'Windows';
  sOSDelim = '\';
EndIf;

## Validate source dir
If( Trim( pSrcDir ) @= '' );
    pSrcDir     = GetProcessErrorFileDirectory;
    sMessage    = 'Source folder defaulted to error file directory.';
    LogOutput( 'INFO', Expand( cMsgErrorContent ) );
EndIf;
If( SubSt( pSrcDir, Long( pSrcDir ), 1 ) @= sOSDelim );
    pSrcDir = SubSt( pSrcDir, 1, Long( pSrcDir ) -1 );
EndIf;
If( FileExists( pSrcDir ) = 0 );
    nErrors     = 1;
    sMessage    = 'Invalid source path specified. Folder does not exist.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;
pSrcDir         = pSrcDir | sOSDelim;

# Validate legacy file format
If( pLegacy <> 1 );
    pLegacy = 0;
EndIf;

# Validate export filename
If( pSrcFile @= '' );
  pSrcFile      = pDim | If( pLegacy = 1, '', ' ' | sHier ) | '_Export.csv';
ElseIf( Scan( '.', pSrcFile ) = 0 );
    # No file extension specified
    pSrcFile    = pSrcFile | '.csv';
EndIf;

# Construct full export filename including path
sFilename       = pSrcDir | pSrcFile;
sAttrDimName    = '}ElementAttributes_' | pDim ;

If( FileExists( sFilename ) = 0 );
    nErrors     = 1;
    sMessage    = 'Invalid path or file name specified. It does not exist.';
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
EndIf;

# Validate unwind
If( pUnwind <> 0 & pUnwind <> 2 );
    pUnwind = 1;
EndIf;

# Validate consolidation to unwind
If( pConsol @= '' );
    # Only check if parameter is passed as empty as this is invalid. Validation in case of element not existng in dimension will be evaluated in the unwind sub-process
    pConsol = '*';
EndIf;

# Validate file delimiter & quote character
If( pDelim @= '' );
    pDelim = ',';
Else;
    # If length of pDelim is exactly 3 chars and each of them is decimal digit, then the pDelim is entered as ASCII code
    nValid = 0;
    If ( LONG(pDelim) = cLenASCIICode );
      nChar = 1;
      While ( nChar <= cLenASCIICode );
        If( CODE( pDelim, nChar )>=CODE( '0', 1 ) & CODE( pDelim, nChar )<=CODE( '9', 1 ) );
          nValid = 1;
        Else;
          nValid = 0;
        EndIf;
        nChar = nChar + 1;
      End;
    EndIf;
    If ( nValid<>0 );
      pDelim=CHAR(StringToNumber( pDelim ));
    Else;
      pDelim = SubSt( Trim( pDelim ), 1, 1 );
    EndIf;
EndIf;
If( pQuote @= '' );
    ## Use no quote character 
Else;
    # If length of pQuote is exactly 3 chars and each of them is decimal digit, then the pQuote is entered as ASCII code
    nValid = 0;
    If ( LONG(pQuote) = cLenASCIICode );
      nChar = 1;
      While ( nChar <= cLenASCIICode );
        If( CODE( pQuote, nChar ) >= CODE( '0', 1 ) & CODE( pQuote, nChar ) <= CODE( '9', 1 ) );
          nValid = 1;
        Else;
          nValid = 0;
        EndIf;
        nChar = nChar + 1;
      End;
    EndIf;
    If ( nValid<>0 );
      pQuote=CHAR(StringToNumber( pQuote ));
    Else;
      pQuote = SubSt( Trim( pQuote ), 1, 1 );
    EndIf;
EndIf;

### Check for errors before continuing
If( nErrors <> 0 );
  If( pStrictErrorHandling = 1 ); 
      ProcessQuit; 
  Else;
      ProcessBreak;
  EndIf;
EndIf;

### Prepare target dimension ###
If( HierarchyExists( pDim, sHier ) = 1 );
    If( pUnwind = 1 );
    ExecuteProcess('}bedrock.hier.unwind', 'pLogOutput', pLogOutput,
      'pStrictErrorHandling', pStrictErrorHandling,
    	'pDim', pDim,
    	'pHier', sHier,
    	'pConsol', pConsol,
    	'pRecursive', 1
    );
    ElseIf( pUnwind = 0 );
        If( pDim @= sHier );
            DimensionDeleteAllElements( pDim );
        Else;
            HierarchyDeleteAllElements( pDim, pHier );
        EndIf;
    EndIf;
Else;
    ExecuteProcess('}bedrock.hier.create',
	'pLogOutput',pLogOutput,
	'pStrictErrorHandling', pStrictErrorHandling,
	'pDim',pDim,
	'pHier',sHier);
EndIf;

If( nErrors = 0 );
    If( HierarchyExists( pDim, sHier ) = 1 );
        IF ( pUnwind = 1 ) ;
            sMessage = 'Dimension unwound: ' | pDim|':'|sHier;
        ELSEIF ( pUnwind = 0 ) ;
            sMessage = 'Dimension rebuilt: ' | pDim|':'|sHier;
        ENDIF ;
    Else;
        sMessage = 'Dimension created: ' | pDim|':'|sHier;
    EndIf;
Else;
    If( pStrictErrorHandling = 1 ); 
        ProcessQuit; 
    Else;
        ProcessBreak;
    EndIf;
EndIf;

### CONSTANTS ###
sAttrDimName    = '}ElementAttributes_' | pDim ;
cCubeS1         = '}DimensionProperties';

#Processbreak;

### Assign Datasource ###
DataSourceType          = 'CHARACTERDELIMITED';
DatasourceNameForServer = sFilename;
DatasourceNameForClient = sFilename;
DatasourceAsciiDelimiter= pDelim;
DatasourceAsciiQuoteCharacter = pQuote;

##### End Prolog #####
573,85
#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### Check for errors before continuing
If( nErrors <> 0 );
  If( pStrictErrorHandling = 1 ); 
      ProcessQuit; 
  Else;
      ProcessBreak;
  EndIf;
EndIf;

If( pDim @= sHier);
    sDim = pDim;
Else;
    sDim = pDim|':'|sHier;
Endif;

### Metadata Count
nMetaCount = nMetaCount + 1;

sVar1 = v1;
sVar2 = v2;
sVar3 = If( pLegacy <> 1, Subst( v3 , Scan( '-' , v3 ) + 1 , Long( v3 ) ), v3 );
sVar4 = If( pLegacy <> 1, Subst( v4 , Scan( '-' , v4 ) + 1 , Long( v4 ) ), v4 );
sVar5 = If( pLegacy <> 1, Subst( v5 , Scan( '-' , v5 ) + 1 , Long( v5 ) ), v5 );

## Set Dimension Sort Order
IF( v1 @= 'Sort parameters :' );
    CELLPUTS( sVar2, cCubeS1 , sDim, 'SORTELEMENTSTYPE' );
    CELLPUTS( sVar3, cCubeS1 , sDim, 'SORTCOMPONENTSTYPE' );
    CELLPUTS( sVar4, cCubeS1 , sDim, 'SORTELEMENTSSENSE' );
    CELLPUTS( sVar5, cCubeS1 , sDim, 'SORTCOMPONENTSSENSE' );
    DimensionSortOrder( sDim, sVar3, sVar5, sVar2, sVar4 );
ElseIF( pLegacy = 1 & nDataCount = 3 & ( sVar1 @= 'BYINPUT' % sVar1 @= 'BYNAME' % sVar1 @= 'BYHIERARCHY' % sVar1 @= 'BYLEVEL' ) );
    CELLPUTS( sVar1, cCubeS1 , sDim, 'SORTELEMENTSTYPE' );
    CELLPUTS( sVar2, cCubeS1 , sDim, 'SORTCOMPONENTSTYPE' );
    CELLPUTS( sVar3, cCubeS1 , sDim, 'SORTELEMENTSSENSE' );
    CELLPUTS( sVar4, cCubeS1 , sDim, 'SORTCOMPONENTSSENSE' );
    DimensionSortOrder( sDim, sVar2, sVar4, sVar1, sVar3 );
ENDIF;

### Build dimension
IF( V1 @= 'A' );
    # insert attributes
    ATTRINSERT( pDim, '', sVar2 , SUBST( sVar3, 2, 1 ) );
    IF( pLogOutput = 1 );
        sMessage    = Expand('Attribute %sVar2% created in %sDim% as type %sVar3%.');
        LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
    ENDIF;
ELSEIF( V1 @= 'E' );
    # insert elements
    If( sHier @= 'Leaves' & sVar3 @<> 'N' );
        IF( pLogOutput = 1 );
            sMessage    = Expand('Invalid element type %sVar3% for Leaves hierachy. Skipping insertion of element %sVar2%.');
            LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
        ENDIF;
        ItemSkip;
    EndIf;
    HierarchyElementInsert( pDim, sHier, '', sVar2 , sVar3 );
    IF( pLogOutput = 1 );
        sMessage    = Expand('Inserted element %sVar2% into %sDim% as type %sVar3%.');
        LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
    ENDIF;
ELSEIF( V1 @= 'P' );
    # create rollups
    If( sHier @= 'Leaves' );
        IF( pLogOutput = 1 );
            sMessage    = Expand('Leaves hierarchy! Skipping mapping of %sVar2% into parent %sVar3%.');
            LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
        ENDIF;
        ItemSkip;
    EndIf;
    HierarchyElementInsert( pDim, sHier, '', sVar3 , sVar4 );
    HierarchyElementComponentAdd( pDim, sHier, sVar3 , sVar2 , StringToNumber( sVar5 ) );
    IF( pLogOutput = 1 );
        sMessage    = Expand('Inserted parent %sVar3% into %sDim% as type %sVar4%. Then added %sVar2% to %sVar3% with a weight of %sVar5%.');
        sMessage    = Expand('Added %sVar2% to %sVar3% with a weight of %sVar5%.');
        LogOutput( 'INFO', Expand( cMsgErrorContent ) );  
    ENDIF;
ENDIF;
574,58
#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### Check for errors before continuing
If( nErrors <> 0 );
  If( pStrictErrorHandling = 1 ); 
      ProcessQuit; 
  Else;
      ProcessBreak;
  EndIf;
EndIf;

### Data Count
nDataCount = nDataCount + 1;

sVar1 = v1;
sVar2 = v2;
sVar3 = If( pLegacy <> 1, Subst( v3 , Scan( '-' , v3 ) + 1 , Long( v3 ) ), v3 );
sVar4 = If( pLegacy <> 1, Subst( v4 , Scan( '-' , v4 ) + 1 , Long( v4 ) ), v4 );
sVar5 = If( pLegacy <> 1, Subst( v5 , Scan( '-' , v5 ) + 1 , Long( v5 ) ), v5 );

If( pDim @= sHier);
    sDim = pDim;
Else;
    sDim = pDim|':'|sHier;
Endif;

### Load Attribute Values ###
IF( V1 @= 'V' );
    sAttrType = DTYPE( sAttrDimName , sVar3 );
    IF ( pDim @<> sHier );
        IF ( CellIsUpdateable ( '}ElementAttributes_' | pDim, sHier:sVar2, sVar3 ) = 0 ) ;
            ItemSkip ;
        ENDIF ;
        IF( sAttrType @= 'AN' );
            ElementAttrPUTN( StringToNumber( sVar4 ), pDim, sHier, sVar2, sVar3 );
        ELSEIF( sAttrType @= 'AA' );
            ElementATTRPUTS( sVar4, pDim, sHier, sVar2, sVar3, 1 );
        ELSE;
            ElementATTRPUTS( sVar4, pDim, sHier, sVar2, sVar3 );
        ENDIF;
    ELSE;
        IF ( CellIsUpdateable ( '}ElementAttributes_' | pDim , sVar2, sVar3 ) = 0 ) ;
            ItemSkip ;
        ENDIF ;
        IF( sAttrType @= 'AN' );
            AttrPUTN( StringToNumber( sVar4 ), pDim, sVar2, sVar3 );
        ELSEIF( sAttrType @= 'AA' );
            ATTRPUTS( sVar4, pDim, sVar2, sVar3, 1 );
        ELSE;
            ATTRPUTS( sVar4, pDim, sVar2, sVar3 );
        ENDIF;        
    ENDIF;
ENDIF;
575,27
#****Begin: Generated Statements***
#****End: Generated Statements****

################################################################################################# 
##~~Join the bedrock TM1 community on GitHub https://github.com/cubewise-code/bedrock Ver 4.0~~##
################################################################################################# 

### If errors occurred terminate process with a major error status ###
If( nErrors > 0 );
    sMessage = 'the process incurred at least 1 major error and consequently aborted. Please see above lines in this file for more details.';
    nProcessReturnCode = 0;
    LogOutput( cMsgErrorLevel, Expand( cMsgErrorContent ) );
    sProcessReturnCode = Expand( '%sProcessReturnCode% Process:%cThisProcName% aborted. Check tm1server.log for details.' );
    If( pStrictErrorHandling = 1 ); 
        ProcessQuit; 
    EndIf;
EndIf;

### Return Code
sProcessAction      = Expand( 'Process:%cThisProcName% successfully imported data from %sFileName% and updated the %pDim%:%pHier% dimension:hierarchy.' );
sProcessReturnCode  = Expand( '%sProcessReturnCode% %sProcessAction%' );
nProcessReturnCode  = 1;
If ( pLogoutput = 1 );
    LogOutput('INFO', Expand( sProcessAction ) );   
EndIf;

### End Epilog ###
576,CubeAction=1511DataAction=1503CubeLogChanges=0
930,0
638,1
804,0
1217,1
900,
901,
902,
938,0
937,
936,
935,
934,
932,0
933,0
903,
906,
929,
907,
908,
904,0
905,0
909,0
911,
912,
913,
914,
915,
916,
917,0
918,1
919,0
920,50000
921,""
922,""
923,0
924,""
925,""
926,""
927,""
