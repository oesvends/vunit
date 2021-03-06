--
--  File Name:         AlertLogPkg.vhd
--  Design Unit Name:  AlertLogPkg
--  Revision:          STANDARD VERSION,  revision 2015.01
--
--  Maintainer:        Jim Lewis      email:  jim@synthworks.com
--  Contributor(s):
--     Jim Lewis      jim@synthworks.com
--
--
--  Description:
--        Alert handling and log filtering (verbosity control)
--        Alert handling provides a method to count failures, errors, and warnings
--          To accumlate counts, a data structure is created in a shared variable
--          It is of type AlertLogStructPType which is defined in AlertLogBasePkg
--        Log filtering provides verbosity control for logs (display or do not display)
--        AlertLogPkg provides a simplified interface to the shared variable 
--          
--
--  Developed for:
--        SynthWorks Design Inc.
--        VHDL Training Classes
--        11898 SW 128th Ave.  Tigard, Or  97223
--        http://www.SynthWorks.com
--
--  Revision History:
--    Date       Version    Description
--    01/2015:   2015.01    Initial revision
--
--
--  Copyright (c) 2015 by SynthWorks Design Inc.  All rights reserved.
--
--  Verbatim copies of this source file may be used and
--  distributed without restriction.
--
--  This source file is free software; you can redistribute it
--  and/or modify it under the terms of the ARTISTIC License
--  as published by The Perl Foundation; either version 2.0 of
--  the License, or (at your option) any later version.
--
--  This source is distributed in the hope that it will be
--  useful, but WITHOUT ANY WARRANTY; without even the implied
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
--  PURPOSE. See the Artistic License for details.
--
--  You should have received a copy of the license with this source.
--  If not download it from,
--     http://www.perlfoundation.org/artistic_license_2_0
--


use std.textio.all ;
use work.OsvvmGlobalPkg.all ; 
use work.TranscriptPkg.all ;

package AlertLogPkg is

  subtype  AlertLogIDType   is integer ;
  type     AlertType        is (FAILURE, ERROR, WARNING) ;  -- NEVER
  subtype  AlertIndexType   is AlertType range FAILURE to WARNING ;
  type     AlertCountType   is array (AlertIndexType) of integer ;
  type     AlertEnableType  is array(AlertIndexType) of boolean ;
  type     LogType          is (ALWAYS, DEBUG, FINAL, INFO) ;  -- NEVER
  subtype  LogIndexType     is LogType range DEBUG to INFO ;
  type     LogEnableType    is array (LogIndexType) of boolean ;

  constant  ALERTLOG_BASE_ID        : AlertLogIDType := 0 ;
  constant  ALERT_DEFAULT_ID        : AlertLogIDType := 1 ;
  constant  LOG_DEFAULT_ID          : AlertLogIDType := 1 ;
  constant  ALERTLOG_DEFAULT_ID     : AlertLogIDType :=  ALERT_DEFAULT_ID ; 
  constant  OSVVM_ALERTLOG_ID       : AlertLogIDType := 2 ;
  constant  ALERTLOG_ID_NOT_FOUND   : AlertLogIDType := -1 ;  -- alternately integer'right
  constant  MIN_NUM_AL_IDS          : AlertLogIDType := 32 ; -- Number IDs initially allocated

  alias AlertLogOptionsType is work.OsvvmGlobalPkg.OsvvmOptionsType ; 

  ------------------------------------------------------------
  --  Alert always goes to the transcript file
  procedure Alert( 
    AlertLogID   : AlertLogIDType ; 
    Message      : string ;
    Level        : AlertType := ERROR  
  ) ;
  procedure Alert( Message : string ; Level : AlertType := ERROR ) ; 
  
  ------------------------------------------------------------
  -- Similar to assert, except condition is positive
  procedure AlertIf( condition : boolean ; AlertLogID : AlertLogIDType ; Message : string ; Level : AlertType := ERROR )  ; 
  procedure AlertIf( condition : boolean ; Message : string ; Level : AlertType := ERROR ) ; 
  impure function  AlertIf( condition : boolean ; AlertLogID : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) return boolean ; 
  impure function  AlertIf( condition : boolean ; Message : string ; Level : AlertType := ERROR ) return boolean ; 

  ------------------------------------------------------------
  -- Direct replacement for assert
  procedure AlertIfNot( condition : boolean ; AlertLogID : AlertLogIDType ; Message : string ; Level : AlertType := ERROR )  ; 
  procedure AlertIfNot( condition : boolean ; Message : string ; Level : AlertType := ERROR ) ; 
  impure function  AlertIfNot( condition : boolean ; AlertLogID : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) return boolean ; 
  impure function  AlertIfNot( condition : boolean ; Message : string ; Level : AlertType := ERROR ) return boolean ; 

  ------------------------------------------------------------
  procedure SetAlertLogJustify ;
  procedure ReportAlerts ( Name : string := OSVVM_STRING_INIT_PARM_DETECT ; AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ; ExternalErrors : AlertCountType := (others => 0) ) ;
  procedure ReportAlerts ( Name : String ; AlertCount : AlertCountType ) ;
  procedure ClearAlerts ; 
  function "+" (L, R : AlertCountType) return AlertCountType ;
  function "-" (L, R : AlertCountType) return AlertCountType ;
  function "-" (R : AlertCountType) return AlertCountType ;
  impure function SumAlertCount(AlertCount: AlertCountType) return integer ;
  impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
  impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer ;
  impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
  impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer ;
  impure function GetDisabledAlertCount return AlertCountType ;
  impure function GetDisabledAlertCount return integer ;
  impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return AlertCountType ;
  impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return integer ;

  ------------------------------------------------------------
  --  log filtering for verbosity control, optionally has a separate file parameter
  procedure Log( 
    AlertLogID   : AlertLogIDType ; 
    Message      : string ;
    Level        : LogType := ALWAYS
  ) ; 
  procedure Log( Message : string ; Level : LogType := ALWAYS) ; 
  
  ------------------------------------------------------------
  -- Accessor Methods
  procedure SetAlertLogName(Name : string ) ;
  procedure InitializeAlertLogStruct ;
  procedure DeallocateAlertLogStruct ;
  impure function FindAlertLogID(Name : string ) return AlertLogIDType ;
  impure function GetAlertLogID(Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertLogIDType ;
  
  ------------------------------------------------------------
  -- Accessor Methods
  procedure SetGlobalAlertEnable (A : boolean := TRUE) ;
  impure function SetGlobalAlertEnable (A : boolean := TRUE) return boolean ;

  procedure SetAlertStopCount(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Count : integer) ;
  procedure SetAlertStopCount(Level : AlertType ;  Count : integer) ;

  procedure SetAlertEnable(Level : AlertType ;  Enable : boolean) ; 
  procedure SetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

  procedure SetLogEnable(Level : LogType ;  Enable : boolean) ; 
  procedure SetLogEnable(AlertLogID : AlertLogIDType ;  Level : LogType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

  impure function IsLoggingEnabled(AlertLogID : AlertLogIDType ; Level : LogType) return boolean ;
  impure function IsLoggingEnabled(Level : LogType) return boolean ; 
  
  ------------------------------------------------------------
  procedure SetAlertLogOptions (
    FailOnWarning         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; 
    FailOnDisabledErrors  : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    ReportHierarchy       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertLevel       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertName        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertTime        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogLevel         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogName          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogTime          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    AlertPrefix           : string := OSVVM_STRING_INIT_PARM_DETECT ;
    LogPrefix             : string := OSVVM_STRING_INIT_PARM_DETECT ;
    ReportPrefix          : string := OSVVM_STRING_INIT_PARM_DETECT ;
    DoneName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
    PassName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
    FailName              : string := OSVVM_STRING_INIT_PARM_DETECT 
  ) ;
  
  -- Used by TextUtilPkg
  impure function GetAlertReportPrefix return string ;
  impure function GetAlertDoneName return string ;
  impure function GetAlertPassName return string ;
  impure function GetAlertFailName return string ;
  
end AlertLogPkg ;

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////

use work.NamePkg.all ;

package body AlertLogPkg is

  -- instead of justify(to_upper(to_string())), just look up the upper case, left justified values
  type     AlertNameType is array(AlertType) of string(1 to 7) ; 
  constant ALERT_NAME : AlertNameType := (WARNING => "WARNING", ERROR => "ERROR  ", FAILURE => "FAILURE") ;  -- , NEVER => "NEVER  "
  type     LogNameType is array(LogType) of string(1 to 7) ; 
  constant LOG_NAME : LogNameType := (DEBUG => "DEBUG  ", FINAL => "FINAL  ", INFO => "INFO   ", ALWAYS => "ALWAYS ") ; -- , NEVER => "NEVER  "

  -- Local
  constant NUM_PREDEFINED_AL_IDS : AlertLogIDType := 2 ;  -- Not including base


  type AlertLogStructPType is protected
  
    ------------------------------------------------------------
    procedure alert ( 
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ; 
      message      : string ;
      level        : AlertType := ERROR
    ) ;
    
    ------------------------------------------------------------
    procedure SetJustify ;
    procedure ReportAlerts ( Name : string := OSVVM_STRING_INIT_PARM_DETECT ; AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ; ExternalErrors : AlertCountType := (0,0,0) ) ;
    procedure ReportAlerts ( Name : string ; AlertCount : AlertCountType ) ;
    procedure ClearAlerts ; 
    impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
    impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType ;
    impure function GetDisabledAlertCount return AlertCountType ;
    impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return AlertCountType ;
    
    ------------------------------------------------------------
    procedure log ( 
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ; 
      Message      : string ;
      Level        : LogType := ALWAYS
    ) ;
    
    ------------------------------------------------------------
    -- FILE IO Controls
--    procedure SetTranscriptEnable (A : boolean := TRUE) ;
--    impure function IsTranscriptEnabled return boolean ;
--    procedure MirrorTranscript (A : boolean := TRUE) ;
--    impure function IsTranscriptMirrored return boolean ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- AlertLog Structure Creation and Interaction Methods

    ------------------------------------------------------------
    procedure SetAlertLogName(Name : string ) ;
    procedure SetNumAlertLogIDs (NewNumAlertLogIDs : integer) ;
    impure function FindAlertLogID(Name : string ) return AlertLogIDType ;
    impure function GetAlertLogID(Name : string ; ParentID : AlertLogIDType) return AlertLogIDType ;
    procedure Initialize(NewNumAlertLogIDs : integer := MIN_NUM_AL_IDS) ;
    procedure Deallocate ;

    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Accessor Methods
    ------------------------------------------------------------
    procedure SetGlobalAlertEnable (A : boolean := TRUE) ;
    
    procedure SetAlertStopCount(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Count : integer) ;

    procedure SetAlertEnable(Level : AlertType ;  Enable : boolean) ; 
    procedure SetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

    procedure SetLogEnable(Level : LogType ;  Enable : boolean) ; 
    procedure SetLogEnable(AlertLogID : AlertLogIDType ;  Level : LogType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) ;

    impure function IsLoggingEnabled(AlertLogID : AlertLogIDType ;  Level : LogType) return boolean ; 
    
    ------------------------------------------------------------
    -- Reporting Accessor
    procedure SetAlertLogOptions (
      FailOnWarning         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; 
      FailOnDisabledErrors  : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      ReportHierarchy       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertLevel       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertName        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertTime        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogLevel         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogName          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogTime          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      AlertPrefix           : string := OSVVM_STRING_INIT_PARM_DETECT ;
      LogPrefix             : string := OSVVM_STRING_INIT_PARM_DETECT ;
      ReportPrefix          : string := OSVVM_STRING_INIT_PARM_DETECT ;
      DoneName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName              : string := OSVVM_STRING_INIT_PARM_DETECT 
    ) ;

    impure function GetAlertReportPrefix return string ;
    impure function GetAlertDoneName return string ;
    impure function GetAlertPassName return string ;
    impure function GetAlertFailName return string ;

  end  protected AlertLogStructPType ; 

  --- ///////////////////////////////////////////////////////////////////////////
  
  type AlertLogStructPType is protected body
  
    variable GlobalAlertEnabled : boolean := TRUE ; -- Allows turn off and on
--    variable TranscriptEnabled  : boolean := FALSE ; 
--    variable TranscriptMirrored : boolean := FALSE ; 
    
    ------------------------------------------------------------
    type AlertLogRecType is record
    ------------------------------------------------------------
      Name              : Line ; 
      ParentID          : AlertLogIDType ; 
      AlertCount        : AlertCountType ; 
      AlertStopCount    : AlertCountType ;
      AlertEnabled      : AlertEnableType ;
      LogEnabled        : LogEnableType ; 
    end record AlertLogRecType ; 
    
    ------------------------------------------------------------
    -- Basis for AlertLog Data Structure 
    variable NumAlertLogIDs      : AlertLogIDType := NUM_PREDEFINED_AL_IDS ; -- Initial number defined
    variable NumAllocatedAlertLogIDs : AlertLogIDType := 0 ; 
    type AlertLogRecPtrType is access AlertLogRecType ; 
    type AlertLogArrayType is array (AlertLogIDType range <>) of AlertLogRecPtrType ; 
    type AlertLogArrayPtrType is access AlertLogArrayType ;
    variable AlertLogPtr  : AlertLogArrayPtrType ;
    
    ------------------------------------------------------------
    -- Report formatting settings, with defaults
    variable FailOnWarningVar          : boolean := TRUE ;
    variable FailOnDisabledErrorsVar   : boolean := TRUE ;
    variable ReportHierarchyVar        : boolean := TRUE ;
    variable HierarchyInUseVar         : boolean := FALSE ;

    variable WriteAlertLevelVar        : boolean := TRUE ;
    variable WriteAlertNameVar         : boolean := TRUE ;
    variable WriteAlertTimeVar         : boolean := TRUE ;
    variable WriteLogLevelVar          : boolean := TRUE ;
    variable WriteLogNameVar           : boolean := TRUE ;
    variable WriteLogTimeVar           : boolean := TRUE ;

    variable AlertPrefixVar            : NamePType ;
    variable LogPrefixVar              : NamePType ;
    variable ReportPrefixVar           : NamePType ;
    variable DoneNameVar               : NamePType ;
    variable PassNameVar               : NamePType ;
    variable FailNameVar               : NamePType ;

    variable AlertLogJustifyAmountVar  : integer := 0 ; 
    variable ReportJustifyAmountVar    : integer := 0 ; 
                  
    ------------------------------------------------------------
    -- PT Local
    impure function LeftJustify(A : String;  Amount : integer) return string is
    ------------------------------------------------------------
      constant Spaces : string(1 to  maximum(1, Amount)) := (others => ' ') ; 
    begin
      if A'length >= Amount then
        return A ; 
      else 
        return A & Spaces(1 to Amount - A'length) ;
      end if ; 
    end function LeftJustify ; 


    ------------------------------------------------------------
    -- PT Local
    procedure IncrementAlertCount(
    ------------------------------------------------------------
      constant AlertLogID     : in    AlertLogIDType ;
      constant Level          : in    AlertType ;
      variable StopDueToCount : inout boolean 
    ) is 
    begin
      -- Always Count at this level
      AlertLogPtr(AlertLogID).AlertCount(Level) := AlertLogPtr(AlertLogID).AlertCount(Level) + 1 ;
      -- Only do remaining actions if enabled
      if AlertLogPtr(AlertLogID).AlertEnabled(Level) then 
        -- Exceeded Stop Count at this level?
        if AlertLogPtr(AlertLogID).AlertCount(Level) >= AlertLogPtr(AlertLogID).AlertStopCount(Level) then 
          StopDueToCount := TRUE ; 
        end if ; 
        -- Propagate counts to parent(s)  -- Ascend Hierarchy
        if AlertLogID /= ALERTLOG_BASE_ID then
          IncrementAlertCount(AlertLogPtr(AlertLogID).ParentID, Level, StopDueToCount) ; 
        end if ; 
      end if ; 
    end procedure IncrementAlertCount ; 

    ------------------------------------------------------------
    procedure alert ( 
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ; 
      message      : string ;
      level        : AlertType := ERROR
    ) is
      variable buf : Line ; 
      constant AlertPrefix : string := ResolveOsvvmOption(AlertPrefixVar.GetOpt,  OSVVM_DEFAULT_ALERT_PREFIX) ;
      variable StopDueToCount : boolean := FALSE ; 
    begin
      if GlobalAlertEnabled then
        -- do not write when disabled
        if AlertLogPtr(AlertLogID).AlertEnabled(Level) then
          write(buf, AlertPrefix) ; 
          if WriteAlertLevelVar then 
            -- write(buf, " " & to_string(Level) ) ; 
            write(buf, " " & ALERT_NAME(Level)) ; -- uses constant lookup
          end if ; 
          if HierarchyInUseVar and WriteAlertNameVar then 
--            write(buf, " in " & justify(AlertLogPtr(AlertLogID).Name.all & ",", LEFT, AlertLogJustifyAmountVar) ) ; 
            write(buf, " in " & LeftJustify(AlertLogPtr(AlertLogID).Name.all & ",", AlertLogJustifyAmountVar) ) ; 
          end if ; 
          write(buf, " " & Message) ; 
          if WriteAlertTimeVar then 
             write(buf, " at " & to_string(NOW, 1 ns)) ; 
          end if ; 
          writeline(buf) ; 
        end if ; 
        -- Always Count
        IncrementAlertCount(AlertLogID, Level, StopDueToCount) ;
        if StopDueToCount then 
          write(buf, LF & AlertPrefix & " Stop Count on " & ALERT_NAME(Level) & " reached") ; 
          if HierarchyInUseVar then 
            write(buf, " in " & AlertLogPtr(AlertLogID).Name.all) ; 
          end if ; 
          write(buf, " at " & to_string(NOW, 1 ns) & " ") ; 
          writeline(buf) ; 
          ReportAlerts ;
          std.env.stop(0) ; 
        end if ; 
      end if ; 
    end procedure alert ; 
    
    ------------------------------------------------------------
    -- PT Local
    impure function CalcJustify (AlertLogID : AlertLogIDType ; CurrentLength : integer ; IndentAmount : integer) return integer_vector is
    ------------------------------------------------------------
      variable ResultValues, LowerLevelValues : integer_vector(1 to 2) ;  -- 1 = Max, 2 = Indented 
    begin
      ResultValues(1) := CurrentLength + 1 ;            -- AlertLogJustifyAmountVar
      ResultValues(2) := CurrentLength + IndentAmount ; -- ReportJustifyAmountVar
      for i in AlertLogID+1 to NumAlertLogIDs loop 
        if AlertLogID = AlertLogPtr(i).ParentID then 
          LowerLevelValues := CalcJustify(i, AlertLogPtr(i).Name'length, IndentAmount + 2) ;
          ResultValues(1)  := maximum(ResultValues(1), LowerLevelValues(1)) ; 
          ResultValues(2)  := maximum(ResultValues(2), LowerLevelValues(2)) ; 
        end if ; 
      end loop ; 
      return ResultValues ; 
    end function CalcJustify ;

    ------------------------------------------------------------
    procedure SetJustify is
    ------------------------------------------------------------
      variable ResultValues : integer_vector(1 to 2) ;  -- 1 = Max, 2 = Indented 
    begin
      ResultValues := CalcJustify(ALERTLOG_BASE_ID, 0, 0) ; 
      AlertLogJustifyAmountVar := ResultValues(1) ; 
      ReportJustifyAmountVar   := ResultValues(2) ; 
    end procedure SetJustify ;

    ------------------------------------------------------------
    -- PT Local
    impure function GetEnabledAlertCount(AlertCount: AlertCountType;  AlertEnabled : AlertEnableType) return AlertCountType is
    ------------------------------------------------------------
      variable Count : AlertCountType := (others => 0) ; 
    begin
      if AlertEnabled(FAILURE) then 
        Count(FAILURE) := AlertCount(FAILURE) ; 
      end if ; 
      if AlertEnabled(ERROR) then 
        Count(ERROR) := AlertCount(ERROR) ; 
      end if ; 
      if FailOnWarningVar and AlertEnabled(WARNING) then 
        Count(WARNING) := AlertCount(WARNING) ; 
      end if ;
      return Count ; 
    end function GetEnabledAlertCount ; 

    ------------------------------------------------------------
    impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType is
    ------------------------------------------------------------
      variable AlertCount : AlertCountType ; 
    begin
      return AlertLogPtr(AlertLogID).AlertCount ; 
    end function GetAlertCount ; 

    ------------------------------------------------------------
    impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType is
    ------------------------------------------------------------
      variable AlertCount : AlertCountType ; 
    begin
      return GetEnabledAlertCount(AlertLogPtr(AlertLogID).AlertCount, AlertLogPtr(AlertLogID).AlertEnabled) ;
    end function GetEnabledAlertCount ; 
    
    ------------------------------------------------------------
    -- PT Local
    impure function GetDisabledAlertCount(AlertCount: AlertCountType;  AlertEnabled : AlertEnableType) return AlertCountType is
    ------------------------------------------------------------
      variable Count : AlertCountType := (others => 0) ; 
    begin
      if not AlertEnabled(FAILURE) then 
        Count(FAILURE) := AlertCount(FAILURE) ; 
      end if ; 
      if not AlertEnabled(ERROR) then 
        Count(ERROR) := AlertCount(ERROR) ; 
      end if ; 
      if FailOnWarningVar and not AlertEnabled(WARNING) then 
        Count(WARNING) := AlertCount(WARNING) ; 
      end if ;
      return Count ; 
    end function GetDisabledAlertCount ; 

    ------------------------------------------------------------
    impure function GetDisabledAlertCount return AlertCountType is
    ------------------------------------------------------------
      variable Count : AlertCountType := (others => 0) ; 
    begin
      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop 
        Count := Count + GetDisabledAlertCount(AlertLogPtr(i).AlertCount, AlertLogPtr(i).AlertEnabled) ;  
      end loop ;
      return Count ; 
    end function GetDisabledAlertCount ; 

    ------------------------------------------------------------
    impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return AlertCountType is
    ------------------------------------------------------------
      variable Count : AlertCountType := (others => 0) ; 
    begin
      Count := GetDisabledAlertCount(AlertLogPtr(AlertLogID).AlertCount, AlertLogPtr(AlertLogID).AlertEnabled) ; 
      for i in AlertLogID+1 to NumAlertLogIDs loop 
        if AlertLogID = AlertLogPtr(i).ParentID then 
          Count := Count + GetDisabledAlertCount(i) ;
        end if ; 
      end loop ; 
      return Count ; 
    end function GetDisabledAlertCount ;
    
    ------------------------------------------------------------
    -- PT Local
    procedure PrintTopAlerts ( 
    ------------------------------------------------------------
      NumErrors          : integer ;
      AlertCount         : AlertCountType ; 
      Name               : string ; 
      NumDisabledErrors  : integer  
    ) is
      constant ReportPrefix    : string := ResolveOsvvmWritePrefix(ReportPrefixVar.GetOpt ) ;
      constant DoneName        : string := ResolveOsvvmDoneName(DoneNameVar.GetOpt     ) ;
      constant PassName        : string := ResolveOsvvmPassName(PassNameVar.GetOpt     ) ;
      constant FailName        : string := ResolveOsvvmFailName(FailNameVar.GetOpt     ) ;
      variable buf : line ; 
    begin
      if NumErrors = 0 then 
        if NumDisabledErrors = 0 then 
          -- Passed
          Write(buf, ReportPrefix & DoneName & "  " & PassName & "  " & Name & 
                     "    at " & to_string(NOW, 1 ns)) ;
          WriteLine(buf) ; 
        else
          -- Failed Due to Disabled Errors
          Write(buf, ReportPrefix & DoneName & "  " & FailName & "  " & Name & 
                     "   Failed Due to Disabled Error(s) = " & to_string(NumDisabledErrors) & 
                     "    at " & to_string(NOW, 1 ns)) ;
          WriteLine(buf) ; 
        end if ; 
      else 
        -- Failed 
        Write(buf, ReportPrefix & DoneName & "  " & FailName & "  "& Name & 
        "  Total Error(s) = "      & to_string(NumErrors) ) ;
        write(buf, "  Failures: "  & to_string(AlertCount(FAILURE)) ) ;
        write(buf, "  Errors: "    & to_string(AlertCount(ERROR) ) ) ;
        write(buf, "  Warnings: "  & to_string(AlertCount(WARNING) ) ) ;
        Write(buf, "  at "  & to_string(NOW, 1 ns)) ;
        WriteLine(buf) ; 
      end if ; 
    end procedure PrintTopAlerts ; 

    ------------------------------------------------------------
    -- PT Local
    procedure PrintChild(
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ;  
      Prefix       : string ;
      IndentAmount : integer 
    ) is 
      variable buf : line ; 
    begin
      for i in AlertLogID+1 to NumAlertLogIDs loop 
        if AlertLogID = AlertLogPtr(i).ParentID then 
          -- Write(buf, Prefix &  " " & AlertLogPtr(i).Name.all ) ;  
--          Write(buf, Prefix &  " " & justify(AlertLogPtr(i).Name.all, LEFT, ReportJustifyAmountVar - IndentAmount)) ;        
          Write(buf, Prefix &  " "   & LeftJustify(AlertLogPtr(i).Name.all, ReportJustifyAmountVar - IndentAmount)) ;        
          write(buf, "  Failures: "  & to_string(AlertLogPtr(i).AlertCount(FAILURE) ) ) ;
          write(buf, "  Errors: "    & to_string(AlertLogPtr(i).AlertCount(ERROR) ) ) ;
          write(buf, "  Warnings: "  & to_string(AlertLogPtr(i).AlertCount(WARNING) ) ) ;
          WriteLine(buf) ; 
          PrintChild(
            AlertLogID    => i, 
            Prefix        => Prefix & "  ", 
            IndentAmount  => IndentAmount + 2
          ) ; 
        end if ; 
      end loop ; 
    end procedure PrintChild ; 

    ------------------------------------------------------------
    procedure ReportAlerts ( Name : string := OSVVM_STRING_INIT_PARM_DETECT ; AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ; ExternalErrors : AlertCountType := (0,0,0) ) is
    ------------------------------------------------------------
      variable NumErrors : integer ; 
      variable NumDisabledErrors : integer ; 
      constant ReportPrefix : string := ResolveOsvvmWritePrefix(ReportPrefixVar.GetOpt) ;
    begin
      if ReportJustifyAmountVar <= 0 then
        SetJustify ; 
      end if ; 
      NumErrors := SumAlertCount(ExternalErrors) + SumAlertCount( GetEnabledAlertCount(AlertLogPtr(AlertLogID).AlertCount, AlertLogPtr(AlertLogID).AlertEnabled)) ;
      if FailOnDisabledErrorsVar then
        NumDisabledErrors := SumAlertCount( GetDisabledAlertCount(AlertLogID) ) ; 
      else
        NumDisabledErrors := 0 ;
      end if ;     
      if IsOsvvmStringSet(Name) then 
        PrintTopAlerts ( 
          NumErrors          => NumErrors, 
          AlertCount         => AlertLogPtr(AlertLogID).AlertCount + ExternalErrors,
          Name               => Name,
          NumDisabledErrors  => NumDisabledErrors
        ) ;
      else
        PrintTopAlerts ( 
          NumErrors          => NumErrors, 
          AlertCount         => AlertLogPtr(AlertLogID).AlertCount + ExternalErrors,
          Name               => AlertLogPtr(AlertLogID).Name.all,
          NumDisabledErrors  => NumDisabledErrors
        ) ;
      end if ; 
      --Print Hierarchy when enabled and error or disabled error
      if (HierarchyInUseVar and ReportHierarchyVar) and (NumErrors /= 0 or NumDisabledErrors /=0) then
        PrintChild(
          AlertLogID    => AlertLogID, 
          Prefix        => ReportPrefix & "  ", 
          IndentAmount  => 2
        ) ; 
      end if ; 
    end procedure ReportAlerts ; 
    
    ------------------------------------------------------------
    procedure ReportAlerts ( Name : string ; AlertCount : AlertCountType ) is
    ------------------------------------------------------------
    begin
       PrintTopAlerts ( 
        NumErrors          => SumAlertCount(AlertCount), 
        AlertCount         => AlertCount,
        Name               => Name,
        NumDisabledErrors  => 0
      ) ;
    end procedure ReportAlerts ; 
  
    ------------------------------------------------------------
    procedure ClearAlerts is
    ------------------------------------------------------------
    begin
      AlertLogPtr(ALERTLOG_BASE_ID).AlertCount := (0, 0, 0) ;
      AlertLogPtr(ALERTLOG_BASE_ID).AlertStopCount := (integer'right, integer'right, 0) ;

      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop 
        AlertLogPtr(i).AlertCount := (0, 0, 0) ; 
        AlertLogPtr(ALERTLOG_BASE_ID).AlertStopCount := (integer'right, integer'right, integer'right) ;
      end loop ; 
    end procedure ClearAlerts ; 

    ------------------------------------------------------------
    -- PT Local
    procedure LocalLog ( 
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ; 
      Message      : string ;
      Level        : LogType  
    ) is
      variable buf : line ; 
      constant LogPrefix : string := ResolveOsvvmOption(LogPrefixVar.GetOpt,  OSVVM_DEFAULT_LOG_PREFIX) ;
    begin
      write(buf, LogPrefix) ; 
      if WriteLogLevelVar then 
        write(buf, " " & LOG_NAME(Level) ) ; 
      end if ; 
      if HierarchyInUseVar and WriteLogNameVar then 
--        write(buf, " in " & justify(AlertLogPtr(AlertLogID).Name.all & ",", LEFT, AlertLogJustifyAmountVar) ) ; 
        write(buf, " in " & LeftJustify(AlertLogPtr(AlertLogID).Name.all & ",", AlertLogJustifyAmountVar) ) ; 
      end if ; 
      write(buf, " " & Message) ; 
      if WriteLogTimeVar then 
         write(buf, " at " & to_string(NOW, 1 ns)) ; 
      end if ; 
      writeline(buf) ; 
    end procedure LocalLog ;     

    ------------------------------------------------------------
    procedure log ( 
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ; 
      Message      : string ;
      Level        : LogType := ALWAYS
    ) is
    begin
      if Level = ALWAYS then 
        LocalLog(AlertLogID, Message, Level) ; 
      elsif AlertLogPtr(AlertLogID).LogEnabled(Level) then
        LocalLog(AlertLogID, Message, Level) ; 
      end if ; 
    end procedure log ;     
       
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- AlertLog Structure Creation and Interaction Methods
        
    ------------------------------------------------------------
    procedure SetAlertLogName(Name : string ) is
    ------------------------------------------------------------
    begin
      Deallocate(AlertLogPtr(ALERTLOG_BASE_ID).Name) ; 
      AlertLogPtr(ALERTLOG_BASE_ID).Name := new string'(Name) ; 
    end procedure SetAlertLogName ; 
    
    ------------------------------------------------------------
    -- PT Local
    procedure NewAlertLogRec(AlertLogID : AlertLogIDType ; Name : string ; ParentID : AlertLogIDType) is
    ------------------------------------------------------------
      variable AlertEnabled   : AlertEnableType ; 
      variable AlertStopCount : AlertCountType ; 
      variable LogEnabled     : LogEnableType ; 
    begin
      if AlertLogID = ALERTLOG_BASE_ID then 
        AlertEnabled := (TRUE, TRUE, TRUE) ; 
        LogEnabled   := (FALSE, FALSE, FALSE) ;
        AlertStopCount := (FAILURE => 0, ERROR => integer'right, WARNING => integer'right) ; 
      else
        AlertEnabled := AlertLogPtr(ALERTLOG_BASE_ID).AlertEnabled ; 
        LogEnabled   := AlertLogPtr(ALERTLOG_BASE_ID).LogEnabled ;
        AlertStopCount := (FAILURE => integer'right, ERROR => integer'right, WARNING => integer'right) ; 
      end if ; 
      AlertLogPtr(AlertLogID) := new AlertLogRecType'(
          Name              => new string'(NAME),
          ParentID          => ParentID,  
          AlertCount        => (0, 0, 0),
          AlertEnabled      => AlertEnabled, 
          AlertStopCount    => AlertStopCount,
          LogEnabled        => LogEnabled
        ) ; 
    end procedure NewAlertLogRec ;

    ------------------------------------------------------------
    -- Construct initial data structure
    procedure Initialize(NewNumAlertLogIDs : integer := MIN_NUM_AL_IDS) is
    ------------------------------------------------------------
    begin
      if NumAllocatedAlertLogIDs /= 0 then
        Alert(ALERT_DEFAULT_ID, "AlertLogPkg: Initialize, data structure already initialized", FAILURE) ; 
        return ; 
      end if ; 
      -- Initialize Pointer
      AlertLogPtr := new AlertLogArrayType(ALERTLOG_BASE_ID to NewNumAlertLogIDs) ;
      NumAllocatedAlertLogIDs := NewNumAlertLogIDs ;
      NumAlertLogIDs := NUM_PREDEFINED_AL_IDS ; 
      -- Create BASE AlertLogID (if it differs from DEFAULT
      if ALERTLOG_BASE_ID /= ALERT_DEFAULT_ID then
        NewAlertLogRec(ALERTLOG_BASE_ID, "AlertLogTop", ALERTLOG_BASE_ID) ;
      end if ; 
      -- Create DEFAULT AlertLogID
      NewAlertLogRec(ALERT_DEFAULT_ID, "Default", ALERTLOG_BASE_ID) ;
      -- Create OSVVM AlertLogID (if it differs from DEFAULT
      if OSVVM_ALERTLOG_ID /= ALERT_DEFAULT_ID then
        NewAlertLogRec(OSVVM_ALERTLOG_ID, "OSVVM", ALERTLOG_BASE_ID) ;
      end if ; 
    end procedure Initialize ;

    ------------------------------------------------------------
    -- PT Local
    -- Constructs initial data structure using constant below 
    impure function Initialize return boolean is
    ------------------------------------------------------------
    begin
      Initialize(MIN_NUM_AL_IDS) ; 
      return TRUE ; 
    end function Initialize ; 
    
    constant CONSTRUCT_ALERT_DATA_STRUCTURE : boolean := Initialize ; 
    
    ------------------------------------------------------------
    procedure Deallocate is
    ------------------------------------------------------------
    begin
      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop 
        Deallocate(AlertLogPtr(i).Name) ; 
        Deallocate(AlertLogPtr(i)) ; 
      end loop ; 
      deallocate(AlertLogPtr) ;
      -- Free up space used by protected types within AlertLogPkg
      AlertPrefixVar.Deallocate ;
      LogPrefixVar.Deallocate ;
      ReportPrefixVar.Deallocate ;
      DoneNameVar.Deallocate ;
      PassNameVar.Deallocate ;
      FailNameVar.Deallocate ;
      -- Restore variables to their initial state
      NumAlertLogIDs                := 0 ; 
      NumAllocatedAlertLogIDs       := 0 ; 
      GlobalAlertEnabled       := TRUE ; -- Allows turn off and on
      FailOnWarningVar         := TRUE ;
      FailOnDisabledErrorsVar  := TRUE ;
      ReportHierarchyVar       := TRUE ;
      HierarchyInUseVar        := FALSE ;
      WriteAlertLevelVar       := TRUE ;
      WriteAlertNameVar        := TRUE ;
      WriteAlertTimeVar        := TRUE ;
      WriteLogLevelVar         := TRUE ;
      WriteLogNameVar          := TRUE ;
      WriteLogTimeVar          := TRUE ;
    end procedure Deallocate ; 

    ------------------------------------------------------------
    -- PT Local.
    procedure GrowAlertStructure (NewNumAlertLogIDs : integer) is
    ------------------------------------------------------------
      variable oldAlertLogPtr : AlertLogArrayPtrType ;
    begin
      if NumAllocatedAlertLogIDs = 0 then
        Initialize (NewNumAlertLogIDs) ;   -- Construct initial structure
      else
        oldAlertLogPtr := AlertLogPtr ;
        AlertLogPtr := new AlertLogArrayType(ALERTLOG_BASE_ID to NewNumAlertLogIDs) ;
        AlertLogPtr(ALERTLOG_BASE_ID to NumAlertLogIDs) := oldAlertLogPtr(ALERTLOG_BASE_ID to NumAlertLogIDs) ;
        deallocate(oldAlertLogPtr) ;
      end if ;
      NumAllocatedAlertLogIDs := NewNumAlertLogIDs ; 
    end procedure GrowAlertStructure ;

    ------------------------------------------------------------
    -- Sets a AlertLogPtr to a particular size
    -- Use for small bins to save space or large bins to
    -- suppress the resize and copy as a CovBin autosizes.
    procedure SetNumAlertLogIDs (NewNumAlertLogIDs : integer) is
    ------------------------------------------------------------
      variable oldAlertLogPtr : AlertLogArrayPtrType ;
    begin
      if NewNumAlertLogIDs > NumAllocatedAlertLogIDs then 
        GrowAlertStructure(NewNumAlertLogIDs) ; 
      end if; 
    end procedure SetNumAlertLogIDs ;
    
    ------------------------------------------------------------
    -- PT Local
    impure function GetNextAlertLogID return AlertLogIDType is
    ------------------------------------------------------------
      variable NormNumAlertLogIDs : AlertLogIDType ;      
    begin
      NumAlertLogIDs := NumAlertLogIDs + 1 ; 
      if NumAlertLogIDs > NumAllocatedAlertLogIDs then
        GrowAlertStructure(NumAllocatedAlertLogIDs + MIN_NUM_AL_IDS) ; 
      end if ; 
      return NumAlertLogIDs ; 
    end function GetNextAlertLogID ;

    ------------------------------------------------------------
    impure function FindAlertLogID(Name : string ) return AlertLogIDType is
    ------------------------------------------------------------
    begin
      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop 
        if Name = AlertLogPtr(i).Name.all then
          return i ;
        end if ; 
      end loop ;
      return ALERTLOG_ID_NOT_FOUND ; -- not found
    end function FindAlertLogID ;


    ------------------------------------------------------------
    impure function GetAlertLogID(Name : string ; ParentID : AlertLogIDType) return AlertLogIDType is
    ------------------------------------------------------------
      variable ResultID : AlertLogIDType ; 
    begin
      ResultID := FindAlertLogID(Name) ; 
      if ResultID /= ALERTLOG_ID_NOT_FOUND then 
        -- found it, set ParentID
        AlertLogPtr(ResultID).ParentID := ParentID ; 
      else
        ResultID := GetNextAlertLogID ; 
        NewAlertLogRec(ResultID, Name, ParentID) ;
        HierarchyInUseVar := TRUE ;
      end if ; 
      return ResultID ; 
    end function GetAlertLogID ; 
    
    ------------------------------------------------------------
    ------------------------------------------------------------
    -- Accessor Methods
    ------------------------------------------------------------
    
    ------------------------------------------------------------
    procedure SetGlobalAlertEnable (A : boolean := TRUE) is
    ------------------------------------------------------------
    begin
      GlobalAlertEnabled := A ;
    end procedure SetGlobalAlertEnable ;
    
    ------------------------------------------------------------
    -- PT LOCAL
    procedure SetOneStopCount(
    ------------------------------------------------------------
      AlertLogID   : AlertLogIDType ;
      Level        : AlertType ;
      Count        : integer 
    ) is 
    begin
      if AlertLogPtr(AlertLogID).AlertStopCount(Level) = integer'right then
        AlertLogPtr(AlertLogID).AlertStopCount(Level) := Count ;
      else
        AlertLogPtr(AlertLogID).AlertStopCount(Level) := 
          AlertLogPtr(AlertLogID).AlertStopCount(Level) + Count ;
      end if ; 
    end procedure SetOneStopCount ;    

    ------------------------------------------------------------
    procedure SetAlertStopCount(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Count : integer) is
    ------------------------------------------------------------
    begin
      SetOneStopCount(AlertLogID, Level, Count) ; 
      if AlertLogID /= ALERTLOG_BASE_ID then 
        SetAlertStopCount(AlertLogPtr(AlertLogID).ParentID, Level, Count) ;
      end if ; 
    end procedure SetAlertStopCount ;    
    
    ------------------------------------------------------------
    procedure SetAlertEnable(Level : AlertType ;  Enable : boolean) is 
    ------------------------------------------------------------
    begin
      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop
        AlertLogPtr(i).AlertEnabled(Level) := Enable ;
      end loop ;
    end procedure SetAlertEnable ;    

    ------------------------------------------------------------
    procedure SetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) is
    ------------------------------------------------------------
    begin
      AlertLogPtr(AlertLogID).AlertEnabled(Level) := Enable ;
      if DescendHierarchy then
        for i in AlertLogID+1 to NumAlertLogIDs loop 
          if AlertLogID = AlertLogPtr(i).ParentID then 
            SetAlertEnable(i, Level, Enable, DescendHierarchy) ; 
          end if ; 
        end loop ;
      end if ; 
    end procedure SetAlertEnable ;  

    ------------------------------------------------------------
    procedure SetLogEnable(Level : LogType ;  Enable : boolean) is 
    ------------------------------------------------------------
    begin
      for i in ALERTLOG_BASE_ID to NumAlertLogIDs loop
        AlertLogPtr(i).LogEnabled(Level) := Enable ;
      end loop ; 
    end procedure SetLogEnable ;    

    ------------------------------------------------------------
    procedure SetLogEnable(AlertLogID : AlertLogIDType ;  Level : LogType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) is
    ------------------------------------------------------------
    begin
      AlertLogPtr(AlertLogID).LogEnabled(Level) := Enable ;
      if DescendHierarchy then
        for i in AlertLogID+1 to NumAlertLogIDs loop 
          if AlertLogID = AlertLogPtr(i).ParentID then 
            SetLogEnable(i, Level, Enable, DescendHierarchy) ; 
          end if ; 
        end loop ;
      end if ; 
    end procedure SetLogEnable ;    

    ------------------------------------------------------------
    impure function IsLoggingEnabled(AlertLogID : AlertLogIDType ;  Level : LogType) return boolean is
    ------------------------------------------------------------
    begin
      if Level = ALWAYS then 
        return TRUE ; 
      else
        return AlertLogPtr(AlertLogID).LogEnabled(Level) ; 
      end if ; 
    end function IsLoggingEnabled ; 

    ------------------------------------------------------------
    procedure SetAlertLogOptions (
    ------------------------------------------------------------
      FailOnWarning         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; 
      FailOnDisabledErrors  : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      ReportHierarchy       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertLevel       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertName        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteAlertTime        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogLevel         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogName          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      WriteLogTime          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
      AlertPrefix           : string := OSVVM_STRING_INIT_PARM_DETECT ;
      LogPrefix             : string := OSVVM_STRING_INIT_PARM_DETECT ;
      ReportPrefix          : string := OSVVM_STRING_INIT_PARM_DETECT ;
      DoneName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
      PassName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
      FailName              : string := OSVVM_STRING_INIT_PARM_DETECT 
    ) is
    begin
      if FailOnWarning /= OPT_INIT_PARM_DETECT then
        FailOnWarningVar := IsEnabled(FailOnWarning) ;
      end if ;
      if FailOnDisabledErrors /= OPT_INIT_PARM_DETECT then
        FailOnDisabledErrorsVar := IsEnabled(FailOnDisabledErrors) ;
      end if ;
      if ReportHierarchy /= OPT_INIT_PARM_DETECT then
        ReportHierarchyVar := IsEnabled(ReportHierarchy) ;
      end if ;
      if WriteAlertLevel /= OPT_INIT_PARM_DETECT then
        WriteAlertLevelVar := IsEnabled(WriteAlertLevel) ;
      end if ;
      if WriteAlertName /= OPT_INIT_PARM_DETECT then
        WriteAlertNameVar := IsEnabled(WriteAlertName) ;
      end if ;
      if WriteAlertTime /= OPT_INIT_PARM_DETECT then
        WriteAlertTimeVar := IsEnabled(WriteAlertTime) ;
      end if ;
      if WriteLogLevel /= OPT_INIT_PARM_DETECT then
        WriteLogLevelVar := IsEnabled(WriteLogLevel) ;
      end if ;
      if WriteLogName /= OPT_INIT_PARM_DETECT then
        WriteLogNameVar := IsEnabled(WriteLogName) ;
      end if ;
      if WriteLogTime /= OPT_INIT_PARM_DETECT then
        WriteLogTimeVar := IsEnabled(WriteLogTime) ;
      end if ;
      if AlertPrefix /= OSVVM_STRING_INIT_PARM_DETECT then
        AlertPrefixVar.Set(AlertPrefix) ; 
      end if ;
      if LogPrefix /= OSVVM_STRING_INIT_PARM_DETECT then
        LogPrefixVar.Set(LogPrefix) ; 
      end if ;
      if ReportPrefix /= OSVVM_STRING_INIT_PARM_DETECT then
        ReportPrefixVar.Set(ReportPrefix) ; 
      end if ;
      if DoneName /= OSVVM_STRING_INIT_PARM_DETECT then
        DoneNameVar.Set(DoneName) ; 
      end if ;
      if PassName /= OSVVM_STRING_INIT_PARM_DETECT then
        PassNameVar.Set(PassName) ; 
      end if ;
      if FailName /= OSVVM_STRING_INIT_PARM_DETECT then
        FailNameVar.Set(FailName) ; 
      end if ;
    end procedure SetAlertLogOptions ;
    
    ------------------------------------------------------------
    impure function GetAlertReportPrefix return string is
    ------------------------------------------------------------
    begin
      return ResolveOsvvmWritePrefix(ReportPrefixVar.GetOpt) ; 
    end function GetAlertReportPrefix ;

    ------------------------------------------------------------
    impure function GetAlertDoneName return string is
    ------------------------------------------------------------
    begin
      return ResolveOsvvmDoneName(DoneNameVar.GetOpt) ; 
    end function GetAlertDoneName ;

    ------------------------------------------------------------
    impure function GetAlertPassName return string is
    ------------------------------------------------------------
    begin
      return ResolveOsvvmPassName(PassNameVar.GetOpt) ; 
    end function GetAlertPassName ;

    ------------------------------------------------------------
    impure function GetAlertFailName return string is
    ------------------------------------------------------------
    begin
      return ResolveOsvvmFailName(FailNameVar.GetOpt) ; 
    end function GetAlertFailName ;
    
  end protected body AlertLogStructPType ;



  shared variable AlertLogStruct : AlertLogStructPType ; 

--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
--- ///////////////////////////////////////////////////////////////////////////
  
  ------------------------------------------------------------
  procedure Alert( 
  ------------------------------------------------------------
    AlertLogID   : AlertLogIDType ; 
    Message      : string  ; 
    Level        : AlertType := ERROR
  ) is
  begin
    AlertLogStruct.Alert(AlertLogID, Message, Level) ; 
  end procedure alert ; 

  ------------------------------------------------------------
  procedure Alert( Message : string ; Level : AlertType := ERROR ) is 
  ------------------------------------------------------------
  begin
    AlertLogStruct.Alert(ALERT_DEFAULT_ID , Message, Level) ; 
  end procedure alert ; 
  
  ------------------------------------------------------------
  procedure AlertIf( condition : boolean ; AlertLogID  : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) is
  ------------------------------------------------------------
  begin
    if condition then
      AlertLogStruct.Alert(AlertLogID , Message, Level) ; 
    end if ; 
  end procedure AlertIf ; 

  ------------------------------------------------------------
  procedure AlertIf( condition : boolean ; Message : string ; Level : AlertType := ERROR ) is
  ------------------------------------------------------------
  begin
    if condition then
      AlertLogStruct.Alert(ALERT_DEFAULT_ID , Message, Level) ; 
    end if ; 
  end procedure AlertIf ;  
  
  ------------------------------------------------------------
  -- useful with exit conditions in a loop:  exit when alert( not ReadValid, failure, "Read Failed") ; 
  impure function  AlertIf( condition : boolean ; AlertLogID  : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) return boolean is
  ------------------------------------------------------------
  begin
    if condition then
      AlertLogStruct.Alert(AlertLogID , Message, Level) ; 
    end if ; 
    return condition ; 
  end function AlertIf ;  
  
  ------------------------------------------------------------
  impure function  AlertIf( condition : boolean ; Message : string ; Level : AlertType := ERROR ) return boolean is
  ------------------------------------------------------------
  begin
    if condition then
      AlertLogStruct.Alert(ALERT_DEFAULT_ID, Message, Level) ; 
    end if ; 
    return condition ; 
  end function AlertIf ;   
  
  ------------------------------------------------------------
  procedure AlertIfNot( condition : boolean ; AlertLogID  : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) is
  ------------------------------------------------------------
  begin
    if not condition then
      AlertLogStruct.Alert(AlertLogID, Message, Level) ; 
    end if ; 
  end procedure AlertIfNot ; 

  ------------------------------------------------------------
  procedure AlertIfNot( condition : boolean ; Message : string ; Level : AlertType := ERROR ) is
  ------------------------------------------------------------
  begin
    if not condition then
      AlertLogStruct.Alert(ALERT_DEFAULT_ID, Message, Level) ; 
    end if ; 
  end procedure AlertIfNot ;  
  
  ------------------------------------------------------------
  -- useful with exit conditions in a loop:  exit when alert( not ReadValid, failure, "Read Failed") ; 
  impure function  AlertIfNot( condition : boolean ; AlertLogID  : AlertLogIDType ; Message : string ; Level : AlertType := ERROR ) return boolean is
  ------------------------------------------------------------
  begin
    if not condition then
      AlertLogStruct.Alert(AlertLogID, Message, Level) ; 
    end if ; 
    return not condition ; 
  end function AlertIfNot ;  
  
  ------------------------------------------------------------
  impure function  AlertIfNot( condition : boolean ; Message : string ; Level : AlertType := ERROR ) return boolean is
  ------------------------------------------------------------
  begin
    if not condition then
      AlertLogStruct.Alert(ALERT_DEFAULT_ID, Message, Level) ; 
    end if ; 
    return not condition ; 
  end function AlertIfNot ;   
  
  ------------------------------------------------------------
  procedure SetAlertLogJustify is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetJustify ;
  end procedure SetAlertLogJustify ; 
  
  ------------------------------------------------------------
  procedure ReportAlerts ( Name : string := OSVVM_STRING_INIT_PARM_DETECT ; AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID ; ExternalErrors : AlertCountType := (others => 0) ) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.ReportAlerts(Name, AlertLogID, ExternalErrors) ; 
  end procedure ReportAlerts ; 

  ------------------------------------------------------------
  procedure ReportAlerts ( Name : String ; AlertCount : AlertCountType ) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.ReportAlerts(Name, AlertCount) ; 
  end procedure ReportAlerts ; 

  ------------------------------------------------------------
  procedure ClearAlerts is
  ------------------------------------------------------------
  begin
    AlertLogStruct.ClearAlerts ; 
  end procedure ClearAlerts ; 

  ------------------------------------------------------------
  function "+" (L, R : AlertCountType) return AlertCountType is
  ------------------------------------------------------------
    variable Result : AlertCountType ; 
  begin
    Result(FAILURE) := L(FAILURE) + R(FAILURE) ; 
    Result(ERROR)   := L(ERROR)   + R(ERROR) ; 
    Result(WARNING) := L(WARNING) + R(WARNING) ; 
    return Result ; 
  end function "+" ;

  ------------------------------------------------------------
  function "-" (L, R : AlertCountType) return AlertCountType is
  ------------------------------------------------------------
    variable Result : AlertCountType ; 
  begin
    Result(FAILURE) := L(FAILURE) - R(FAILURE) ; 
    Result(ERROR)   := L(ERROR)   - R(ERROR) ; 
    Result(WARNING) := L(WARNING) - R(WARNING) ; 
    return Result ; 
  end function "-" ;

  ------------------------------------------------------------
  function "-" (R : AlertCountType) return AlertCountType is
  ------------------------------------------------------------
    variable Result : AlertCountType ; 
  begin
    Result(FAILURE) := - R(FAILURE) ; 
    Result(ERROR)   := - R(ERROR) ; 
    Result(WARNING) := - R(WARNING) ; 
    return Result ; 
  end function "-" ;
  
  ------------------------------------------------------------
  impure function SumAlertCount(AlertCount: AlertCountType) return integer is
  ------------------------------------------------------------
  begin
    return AlertCount(FAILURE) + AlertCount(ERROR) + AlertCount(WARNING) ; 
  end function SumAlertCount ; 

  ------------------------------------------------------------
  impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertCount(AlertLogID) ; 
  end function GetAlertCount ; 
    
  ------------------------------------------------------------
  impure function GetAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer is
  ------------------------------------------------------------
  begin
    return SumAlertCount(AlertLogStruct.GetAlertCount(AlertLogID)) ; 
  end function GetAlertCount ; 

  ------------------------------------------------------------
  impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertCountType is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetEnabledAlertCount(AlertLogID) ; 
  end function GetEnabledAlertCount ; 
    
  ------------------------------------------------------------
  impure function GetEnabledAlertCount(AlertLogID : AlertLogIDType := ALERTLOG_BASE_ID) return integer is
  ------------------------------------------------------------
  begin
    return SumAlertCount(AlertLogStruct.GetEnabledAlertCount(AlertLogID)) ; 
  end function GetEnabledAlertCount ; 

  ------------------------------------------------------------
  impure function GetDisabledAlertCount return AlertCountType is
  ------------------------------------------------------------
   begin
    return AlertLogStruct.GetDisabledAlertCount ; 
  end function GetDisabledAlertCount ; 

  ------------------------------------------------------------
  impure function GetDisabledAlertCount return integer is
  ------------------------------------------------------------
   begin
    return SumAlertCount(AlertLogStruct.GetDisabledAlertCount) ; 
  end function GetDisabledAlertCount ; 

  ------------------------------------------------------------
  impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return AlertCountType is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetDisabledAlertCount(AlertLogID) ; 
  end function GetDisabledAlertCount ; 
  
  ------------------------------------------------------------
  impure function GetDisabledAlertCount(AlertLogID: AlertLogIDType) return integer is
  ------------------------------------------------------------
  begin
    return SumAlertCount(AlertLogStruct.GetDisabledAlertCount(AlertLogID)) ; 
  end function GetDisabledAlertCount ; 
  
  ------------------------------------------------------------
  procedure log( 
  ------------------------------------------------------------
    AlertLogID   : AlertLogIDType ; 
    Message      : string ; 
    Level        : LogType := ALWAYS
  ) is
  begin
    AlertLogStruct.Log(AlertLogID, Message, Level) ; 
  end procedure log ;
  
  ------------------------------------------------------------
  procedure log( Message : string ; Level : LogType := ALWAYS) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.Log(LOG_DEFAULT_ID, Message, Level) ; 
  end procedure log ;
    
  ------------------------------------------------------------
  impure function IsLoggingEnabled(AlertLogID : AlertLogIDType ; Level : LogType) return boolean is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.IsLoggingEnabled(AlertLogID, Level) ;
  end function IsLoggingEnabled ; 
    
  ------------------------------------------------------------
  impure function IsLoggingEnabled(Level : LogType) return boolean is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.IsLoggingEnabled(LOG_DEFAULT_ID, Level) ;
  end function IsLoggingEnabled ; 
    
  ------------------------------------------------------------
  procedure SetAlertLogName(Name : string ) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetAlertLogName(Name) ;
  end procedure SetAlertLogName ;
  
  ------------------------------------------------------------
  procedure InitializeAlertLogStruct is
  ------------------------------------------------------------
  begin
    AlertLogStruct.Initialize ;
  end procedure InitializeAlertLogStruct ;
  
  ------------------------------------------------------------
  procedure DeallocateAlertLogStruct is
  ------------------------------------------------------------
  begin
    AlertLogStruct.Deallocate ;
  end procedure DeallocateAlertLogStruct ; 

  ------------------------------------------------------------
  impure function FindAlertLogID(Name : string ) return AlertLogIDType is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.FindAlertLogID(Name) ;
  end function FindAlertLogID ;
  
  ------------------------------------------------------------
  impure function GetAlertLogID(Name : string ; ParentID : AlertLogIDType := ALERTLOG_BASE_ID) return AlertLogIDType is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertLogID(Name, ParentID ) ;
  end function GetAlertLogID ;
  
  ------------------------------------------------------------
  procedure SetGlobalAlertEnable (A : boolean := TRUE) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetGlobalAlertEnable(A) ;
  end procedure SetGlobalAlertEnable ;
  
  ------------------------------------------------------------
  -- Set using constant.  Set before code runs.
  impure function SetGlobalAlertEnable (A : boolean := TRUE) return boolean is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetGlobalAlertEnable(A) ;
    return A ;  
  end function SetGlobalAlertEnable ;

  ------------------------------------------------------------
  procedure SetAlertStopCount(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Count : integer) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetAlertStopCount(AlertLogID, Level, Count) ;
  end procedure SetAlertStopCount ;    

  ------------------------------------------------------------
  procedure SetAlertStopCount(Level : AlertType ;  Count : integer) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetAlertStopCount(ALERTLOG_BASE_ID, Level, Count) ;
  end procedure SetAlertStopCount ;    

  ------------------------------------------------------------
  procedure SetAlertEnable(Level : AlertType ;  Enable : boolean) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetAlertEnable(Level, Enable) ;
  end procedure SetAlertEnable ;    

  ------------------------------------------------------------
  procedure SetAlertEnable(AlertLogID : AlertLogIDType ;  Level : AlertType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetAlertEnable(AlertLogID, Level, Enable, DescendHierarchy) ;
  end procedure SetAlertEnable ;    
  
  ------------------------------------------------------------
  procedure SetLogEnable(Level : LogType ;  Enable : boolean) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetLogEnable(Level, Enable) ;
  end procedure SetLogEnable ;    

  ------------------------------------------------------------
  procedure SetLogEnable(AlertLogID : AlertLogIDType ;  Level : LogType ;  Enable : boolean ; DescendHierarchy : boolean := TRUE) is
  ------------------------------------------------------------
  begin
    AlertLogStruct.SetLogEnable(AlertLogID, Level, Enable, DescendHierarchy) ;
  end procedure SetLogEnable ;    

  ------------------------------------------------------------
  procedure SetAlertLogOptions (
  ------------------------------------------------------------
    FailOnWarning         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ; 
    FailOnDisabledErrors  : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    ReportHierarchy       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertLevel       : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertName        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteAlertTime        : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogLevel         : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogName          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    WriteLogTime          : AlertLogOptionsType := OPT_INIT_PARM_DETECT ;
    AlertPrefix           : string := OSVVM_STRING_INIT_PARM_DETECT ;
    LogPrefix             : string := OSVVM_STRING_INIT_PARM_DETECT ;
    ReportPrefix          : string := OSVVM_STRING_INIT_PARM_DETECT ;
    DoneName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
    PassName              : string := OSVVM_STRING_INIT_PARM_DETECT ;
    FailName              : string := OSVVM_STRING_INIT_PARM_DETECT 
  ) is
  begin
    AlertLogStruct.SetAlertLogOptions (
      FailOnWarning         => FailOnWarning       ,
      FailOnDisabledErrors  => FailOnDisabledErrors,
      ReportHierarchy       => ReportHierarchy     ,
      WriteAlertLevel       => WriteAlertLevel     ,
      WriteAlertName        => WriteAlertName     ,
      WriteAlertTime        => WriteAlertTime      ,
      WriteLogLevel         => WriteLogLevel       ,
      WriteLogName          => WriteLogName       ,
      WriteLogTime          => WriteLogTime        ,
      AlertPrefix           => AlertPrefix         ,
      LogPrefix             => LogPrefix           ,
      ReportPrefix          => ReportPrefix        ,
      DoneName              => DoneName            ,
      PassName              => PassName            ,
      FailName              => FailName           
    ); 
  end procedure SetAlertLogOptions ;
    
  ------------------------------------------------------------
  impure function GetAlertReportPrefix return string is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertReportPrefix ; 
  end function GetAlertReportPrefix ;
  
  ------------------------------------------------------------
  impure function GetAlertDoneName return string is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertDoneName ; 
  end function GetAlertDoneName ;

  ------------------------------------------------------------
  impure function GetAlertPassName return string is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertPassName ; 
  end function GetAlertPassName ;

  ------------------------------------------------------------
  impure function GetAlertFailName return string is
  ------------------------------------------------------------
  begin
    return AlertLogStruct.GetAlertFailName ; 
  end function GetAlertFailName ;
 
end package body AlertLogPkg ;