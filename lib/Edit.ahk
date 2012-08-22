/*
Title: Edit Library v1.2

Group: Introduction

    This library is designed for use on the standard edit control.


Group: Issues/Consideration

    A few considerations...

 -  Although most of the functions work on all types of edit
    controls -- single-line, multiline, and combo boxes (contains a single-line
    edit control) -- there are several functions that only work on one type of
    edit control.  See the documentation for each function for more information.

 -  AutoHotkey supports the creation and manipulation of the standard edit
    control. For this reason, there are a small number functions that were
    intentionally left out of this library because they provide no additional
    value to what the standard AutoHotkey commands provide.

 -  The edit control does not support several key messages that are needed by
    this library.  Absent messages include EM_GETSELTEXT, EM_GETTEXTRANGE, and
    EM_FINDTEXT.  These messages have been replaced with AutoHotkey commands or
    with other messages.  Although the substitute code/messages are very
    capable, they are not quite as efficient (memory and/or speed) as the
    messages they replace (if they existed).  These inefficiencies are not
    really noticable if the control only contains a limited amount of text
    (~512K or less), but they become more pronounced with increasing text sizes.
    Efficiency also depends on the where work in the control is being done.  For
    example, extracting text from the top of the control uses less resources
    that extracting text from the end of the control.


Group: Credit

    This library was inspired by the Edit mini-library created by *Lexikos* and
    the HiEditor library created by *majkinetor*.  Some of the syntax and code
    ideas were extracted from these libraries.  Thanks to these authors for
    sharing their work.


Group: Functions
*/


;-----------------------------
;
; Function: Edit_ANSI2Unicode
;
; Description:
;
;   Maps a character string (ANSI) to a UTF-16 (wide character) string.
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   lpMultiByteStr - Address to a character string (ANSI).
;
;   WideCharStr - Variable to store the UTF-16 (wide character) string.
;
; Remarks:
;
;   Function adapted from the COM library.  Original author: *Sean*
;
;-------------------------------------------------------------------------------
Edit_ANSI2Unicode(lpMultiByteStr,ByRef WideCharStr)
    {
    Static CP_ACP:=0    ;-- The system default Windows ANSI code page.

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Collect size, in characters
    nSize:=DllCall("MultiByteToWideChar"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT, in]
            ,"UInt",0
                ;-- dwFlags [DWORD, in]
            ,PtrType,lpMultiByteStr
                ;-- lpMultiByteStr [LPCSTR, in].  Pointer to the character
                ;   string to convert.
            ,"Int",-1
                ;-- cbMultiByte [Int, in].  Size, in bytes, of the string
                ;   indicated by the lpMultiByteStr parameter. -1=Process the
                ;   entire string, including terminating null.
            ,PtrType,0
                ;-- lpWideCharStr [LPWSTR, out].  Pointer to a buffer that
                ;   receives the converted string.  Not used here.
            ,"Int",0)
                ;-- cchWideChar [Int, in].  Size, in characters, of the buffer
                ;   indicated by lpWideCharStr.  If 0, the function returns the
                ;   required buffer size, in characters, including any
                ;   terminating null character.

    ;-- Convert
    VarSetCapacity(WideCharStr,nSize*2,0)  ;-- Size in bytes
    DllCall("MultiByteToWideChar"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT, in]
            ,"UInt",0
                ;-- dwFlags [DWORD, in]
            ,PtrType,lpMultiByteStr
                ;-- lpMultiByteStr [LPCSTR, in].  Pointer to the character
                ;   string to convert.
            ,"Int",nSize
                ;-- cbMultiByte [Int, in].  Size, in bytes, of the string
                ;   indicated by the lpMultiByteStr parameter.
            ,"Str",WideCharStr
                ;-- lpWideCharStr [LPWSTR, out].  Pointer to a buffer that
                ;   receives the converted string.
            ,"Int",nSize)
                ;-- cchWideChar [Int, in].  Size, in characters, of the buffer
                ;   indicated by lpWideCharStr.

    Return &WideCharStr
    }


;-----------------------------
;
; Function: Edit_CanUndo
;
; Description:
;
;   Returns TRUE if there are any actions in the edit control's undo queue,
;   otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_CanUndo(hEdit)
    {
    Static EM_CANUNDO:=0xC6
    SendMessage EM_CANUNDO,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_CharFromPos
;
; Description:
;
;   Gets information about the character and/or line closest to a specified
;   point in the the client area of the edit control.
;
; Parameters:
;
;   X, Y - The coordinates of a point in the edit control's client area
;       relative to the upper-left corner of the client area.
;
;   r_CharPos - The zero-based index of the character nearest the specified
;       point. [Optional] This index is relative to the beginning of the
;       control, not the beginning of the line. If the specified point is beyond
;       the last character in the edit control, the return value indicates the
;       last character in the control.  See the *Remarks* section for more
;       information.
;
;   r_LineIdx - Zero-based index of the line that contains the character.
;       [Optional] For single-line edit controls, this value is zero.  The index
;       indicates the line delimiter if the specified point is beyond the last
;       visible character in a line.  See the *Remarks* section for more
;       information.
;
; Returns:
;
;   The value of the r_CharPos variable.
;
; Calls To Other Functions:
;
; * <Edit_GetFirstVisibleLine>
; * <Edit_LineIndex>
;
; Remarks:
;
;   If the specified point is outside the bounds of the edit control, all output
;   variables (Return, r_CharPos, and r_LineIdx) are set to -1.
;
;-------------------------------------------------------------------------------
Edit_CharFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
    {
    Static EM_CHARFROMPOS:=0xD7
    SendMessage EM_CHARFROMPOS,0,(Y<<16)|X,,ahk_id %hEdit%

    ;-- Out of bounds?
    if (ErrorLevel=0xFFFFFFFF)
        {
        r_CharPos:=-1
        r_LineIdx:=-1
        Return r_CharPos
        }

    ;-- Extract values (UShort)
    r_CharPos:=ErrorLevel&0xFFFF    ;-- LOWORD
    r_LineIdx:=ErrorLevel>>16       ;-- HIWORD

    ;-- Convert to UInt using known UInt values as reference
    FirstLine:=Edit_GetFirstVisibleLine(hEdit)-1
    if (FirstLine>r_LineIdx)
        r_LineIdx:=r_LineIdx+(65536*Floor((FirstLine+(65535-r_LineIdx))/65536))

    FirstCharPos:=Edit_LineIndex(hEdit,FirstLine<0 ? 0:FirstLine)
    if (FirstCharPos>r_CharPos)
        r_CharPos:=r_CharPos+(65536*Floor((FirstCharPos+(65535-r_CharPos))/65536))

    Return r_CharPos
    }


;-----------------------------
;
; Function: Edit_Clear
;
; Description:
;
;   Clear (delete) the current selection, if any, from the edit control.
;
; Remarks:
;
;   Undo can be used to reverse this action.
;
;-------------------------------------------------------------------------------
Edit_Clear(hEdit)
    {
    Static WM_CLEAR:=0x303
    SendMessage WM_CLEAR,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_Convert2DOS
;
; Description:
;
;   Converts Unix, DOS/Unix mix, and Mac file formats to DOS format.
;
;-------------------------------------------------------------------------------
Edit_Convert2DOS(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`n,All     ;-- Convert DOS to Unix
    StringReplace p_Text,p_Text,`r,`n,All       ;-- Convert Mac to Unix
    StringReplace p_Text,p_Text,`n,`r`n,All     ;-- Convert Unix to DOS
    Return p_Text
    }


;-----------------------------
;
; Function: Edit_Convert2Mac
;
; Description:
;
;   Convert DOS, DOS/Unix mix, and Unix file formats to Mac format.
;
;-------------------------------------------------------------------------------
Edit_Convert2Mac(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`r,All     ;-- Convert DOS to Mac
    StringReplace p_Text,p_Text,`n,`r,All       ;-- Convert Unix to Mac
    if StrLen(p_Text)
        if SubStr(p_Text,0)<>"`r"
            p_Text.="`r"

    Return p_Text
    }


;-----------------------------
;
; Function: Edit_Convert2Unix
;
; Description:
;
;   Convert DOS, DOS/Unix mix, and Mac formats to Unix format.
;
;-------------------------------------------------------------------------------
Edit_Convert2Unix(p_Text)
    {
    StringReplace p_Text,p_Text,`r`n,`n,All     ;-- Convert DOS to Unix
    StringReplace p_Text,p_Text,`r,`n,All       ;-- Convert Mac to Unix
    if StrLen(p_Text)
        if SubStr(p_Text,0)<>"`n"
            p_Text.="`n"

    Return p_Text
    }


;-----------------------------
;
; Function: Edit_ConvertCase
;
; Description:
;
;   Convert case of selected text.
;
; Parameters:
;
;   p_Case - Set to "Upper", "Lower", "Capitalize", "Sentence", or "Toggle".
;
; Calls To Other Functions:
;
; * <Edit_GetSel>
; * <Edit_GetSelText>
; * <Edit_ReplaceSel>
; * <Edit_SetSel>
;
;-------------------------------------------------------------------------------
Edit_ConvertCase(hEdit,p_Case)
    {
    StringUpper,p_Case,p_Case,T  ;-- Just in case StringCaseSense is On

    ;-- Collect current select postions
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    if (l_StartSelPos=l_EndSelPos)  ;-- Nothing selected
        Return

    ;-- Collect selected text
    l_SelectedText:=Edit_GetSelText(hEdit)
    if l_SelectedText is Space
        Return

    ;-- Convert
    if p_Case in U,Upper,Uppercase
        StringUpper l_SelectedText,l_SelectedText
     else
        if p_Case in L,Lower,Lowercase
            StringLower l_SelectedText,l_SelectedText
         else
            if p_Case in C,Capitalize,Title,Titlecase
                StringLower l_SelectedText,l_SelectedText,T
             else
                if p_Case in S,Sentence,Sentencecase
                    {
                    StringLower l_SelectedText,l_SelectedText
                    l_SelectedText:=RegExReplace(l_SelectedText,"((?:^|[.!?]\s+)[a-z])","$u1")
                        ;-- Note: This pattern provided by ManaUser
                    }
                 else
                    if p_Case in T,Toggle,Togglecase,I,Invert,Invertcase
                        {
                        t_SelectedText:=""
                        Loop Parse,l_SelectedText
                            {
                            t_Char:=A_LoopField
                            if t_Char is Upper
                                StringLower t_Char,t_Char
                             else
                                if t_Char is Lower
                                    StringUpper t_Char,t_Char

                            t_SelectedText.=t_Char
                            }

                        l_SelectedText:=t_SelectedText
                        }

    ;-- Replace selected text with converted text
    Edit_ReplaceSel(hEdit,l_SelectedText)

    ;-- Reselect to the user's original positions
    Edit_SetSel(hEdit,l_StartSelPos,l_EndSelPos)
    }


;-----------------------------
;
; Function: Edit_Copy
;
; Description:
;
;   Copy the current selection to the clipboard in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Copy(hEdit)
    {
    Static WM_COPY:=0x301
    SendMessage WM_COPY,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_Cut
;
; Description:
;
;   Delete the current selection, if any, and copy the deleted text to the
;   clipboard in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Cut(hEdit)
    {
    Static WM_CUT:=0x300
    SendMessage WM_CUT,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_EmptyUndoBuffer
;
; Description:
;
;   Resets the undo flag of the edit control. The undo flag is set whenever an
;   operation within the edit control can be undone.
;
;-------------------------------------------------------------------------------
Edit_EmptyUndoBuffer(hEdit)
    {
    Static EM_EMPTYUNDOBUFFER:=0xCD
    SendMessage EM_EMPTYUNDOBUFFER,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_FindText
;
; Description:
;
;   Find text within the edit control.
;
; Parameters:
;
;   p_SearchText - Search text.
;
;   p_Min, p_Max -  Zero-based search range within the edit control. p_Min is
;       the character index of the first character in the range and p_Max is the
;       character index immediately following the last character in the range.
;       (Ex: To search the first 5 characters of the text, set p_Min to 0 and
;       p_Max to 5)  Set p_Max to -1 to search to the end of the text. To search
;       backward, the roles and descriptions of the p_Min and p_Max are
;       reversed. (Ex: To search the first 5 characters of the control in
;       reverse, set p_Min to 5 and p_Max to 0)
;
;   p_Flags - Valid flags are as follows:
;
;       (Start code)
;       Flag        Description
;       ----        -----------
;       MatchCase   Search is case sensitive.  This flag is ignored if the
;                   "RegEx" flag is also defined.
;
;       RegEx       Regular expression search.
;
;       Static      [Advanced feature]
;                   Text collected from the edit control remains in memory is
;                   used to satisfy the search request.  The text remains in
;                   memory until the "Reset" flag is used or until the
;                   "Static" flag is not used.
;
;                   Advantages: Search time is reduced 10 to 60 percent
;                   (or more) depending on the size of the text in the control.
;                   There is no speed increase on the first use of the "Static"
;                   flag.
;
;                   Disadvantages: Any changes in the edit control are not
;                   reflected in the search.
;
;                   Hint: Don't use this flag unless performing multiple search
;                   requests on a control that will not be modified while
;                   searching.
;
;       Reset       [Advanced feature]
;                   Clears the saved text created by the "Static" flag so that
;                   the next use of the "Static" flag will get the text directly
;                   from the edit control.  To clear the saved memory without
;                   performing a search, use the following syntax:
;
;                       Edit_FindText("","",0,0,"Reset")
;       (end)
;
;
;   r_RegExOutput - Variable that contains the part of the source text that
;       matched the RegEx pattern. [Optional]
;
; Returns:
;
;   Zero-based character index of the first character of the match or -1 if no
;   match is found.
;
; Calls To Other Functions:
;
; * <Edit_GetText>
; * <Edit_GetTextLength>
; * <Edit_GetTextRange>
;
; Programming Notes:
;
;   Searching using regular expressions (RegEx) can produce results that have a
;   dynamic number of characters.  For this reason, searching for the "next"
;   pattern (forward or backward) may produce different results from developer
;   to developer depending on how the values of p_Min and p_Max are determined.
;
;-------------------------------------------------------------------------------
Edit_FindText(hEdit,p_SearchText,p_Min=0,p_Max=-1,p_Flags="",ByRef r_RegExOut="")
    {
    Static s_Text

    ;-- Initialize
    r_RegExOut:=""
    if InStr(p_Flags,"Reset")
        s_Text:=""

    ;-- Anything to search?
    if StrLen(p_SearchText)=0
        Return -1

    l_MaxLen:=Edit_GetTextLength(hEdit)
    if (l_MaxLen=0)
        Return -1

    ;-- Parameters
    if (p_Min<0 or p_Max>l_MaxLen)
        p_Min:=l_MaxLen

    if (p_Max<0 or p_Max>l_MaxLen)
        p_Max:=l_MaxLen

    ;-- Anything to search?
    if (p_Min=p_Max)
        Return -1

    ;-- Get text
    if InStr(p_Flags,"Static")
        {
        if StrLen(s_Text)=0
            s_Text:=Edit_GetText(hEdit)

        l_Text:=SubStr(s_Text,(p_Max>p_Min) ? p_Min+1:p_Max+1,(p_Max>p_Min) ? p_Max:p_Min)
        }
     else
        {
        s_Text:=""
        l_Text:=Edit_GetTextRange(hEdit,(p_Max>p_Min) ? p_Min:p_Max,(p_Max>p_Min) ? p_Max:p_Min)
        }

    ;-- Look for it
    if InStr(p_Flags,"RegEx")=0  ;-- Not RegEx
        l_FoundPos:=InStr(l_Text,p_SearchText,InStr(p_Flags,"MatchCase"),(p_Max>p_Min) ? 1:0)-1
     else  ;-- RegEx
        {
        p_SearchText:=RegExReplace(p_SearchText,"^P\)?","",1)   ;-- Remove P or P)
        if (p_Max>p_Min)  ;-- Search forward
            {
            l_FoundPos:=RegExMatch(l_Text,p_SearchText,r_RegExOut,1)-1
            if ErrorLevel
                {
                outputdebug,
                   (ltrim join`s
                    Function: %A_ThisFunc% - RegExMatch error.
                    ErrorLevel=%ErrorLevel%
                   )

                l_FoundPos:=-1
                }
            }
         else  ;-- Search backward
            {
            ;-- Programming notes:
            ;
            ;    -  The first search begins from the user-defined minimum
            ;       position. This will establish the true minimum position to
            ;       begin search calculations.  If nothing is found, no
            ;       additional searching is necessary.
            ;
            ;    -  The RE_MinPos, RE_MaxPos, and RE_StartPos variables contain
            ;       1-based values.
            ;
            RE_MinPos     :=1
            RE_MaxPos     :=StrLen(l_Text)
            RE_StartPos   :=RE_MinPos
            Saved_FoundPos:=-1
            Saved_RegExOut:=""
            Loop
                {
                ;-- Positional search.  Last found match (if any) wins
                l_FoundPos:=RegExMatch(l_Text,p_SearchText,r_RegExOut,RE_StartPos)-1
                if ErrorLevel
                    {
                    outputdebug,
                       (ltrim join`s
                        Function: %A_ThisFunc% - RegExMatch error.
                        ErrorLevel=%ErrorLevel%
                       )

                    l_FoundPos:=-1
                    Break
                    }

                ;-- If found, update saved and RE_MinPos, else update RE_MaxPos
                if (l_FoundPos>-1)
                    {
                    Saved_FoundPos:=l_FoundPos
                    Saved_RegExOut:=r_RegExOut
                    RE_MinPos     :=l_FoundPos+2
                    }
                else
                    RE_MaxPos:=RE_StartPos-1

                ;-- Are we done?
                if (RE_MinPos>RE_MaxPos or RE_MinPos>StrLen(l_Text))
                    {
                    l_FoundPos:=Saved_FoundPos
                    r_RegExOut:=Saved_RegExOut
                    Break
                    }

                ;-- Calculate new start position
                RE_StartPos:=RE_MinPos+Floor((RE_MaxPos-RE_MinPos)/2)
                }
            }
        }

    ;-- Adjust FoundPos
    if (l_FoundPos>-1)
        l_FoundPos+=(p_Max>p_Min) ? p_Min:p_Max

    Return l_FoundPos
    }

;-----------------------------
;
; Function: Edit_FindTextReset
;
; Description:
;
;   Clears the saved text created by the "Static" flag.
;
;-------------------------------------------------------------------------------
Edit_FindTextReset()
    {
    Edit_FindText("","",0,0,"Reset")
    }


;-----------------------------
;
; Function: Edit_FmtLines
;
; Description:
;
;   Sets a flag that determines whether a multiline edit control includes soft
;   line-break characters. A soft line break consists of two carriage returns
;   and a line feed and is inserted at the end of a line that is broken because
;   of word wrapping.
;
; Parameters:
;
;   p_Flag - Set to TRUE to insert soft line-break characters characters, FALSE
;       to removes them.
;
; Returns:
;
;   The value of p_Flag.
;
; Remarks:
;
;   This message has no effect on the display of the text within the edit
;   control.  It affects the buffer returned by the EM_GETHANDLE message and
;   the text returned by the WM_GETTEXT message.  Since the WM_GETTEXT message
;   is used by other functions in this library, be sure to un-format the text as
;   soon as possible.  Example of use:
;
;       (start code)
;       Edit_FmtLines(hEdit,True)
;       FormattedText:=Edit_GetText(hEdit)
;       Edit_FmtLines(hEdit,False)
;       (end)
;
;-------------------------------------------------------------------------------
Edit_FmtLines(hEdit,p_Flag)
    {
    Static EM_FMTLINES:=0xC8
    SendMessage EM_FMTLINES,p_Flag,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetCueBanner
;
; Description:
;
;   Gets the text that is displayed as the textual cue, or tip, in an edit
;   control.
;
; Parameters:
;
;   p_MaxSize - The maximum number of characters including the terminating null.
;       [Optional] The default is 2048.
;
; Returns:
;
;   Cue bannter text from the designated control.
;
; Requirements:
;
;   Documented:  Windows XP+,
;   Observation: Vista+
;
; Calls To Other Functions:
;
; * <Edit_Unicode2ANSI>
;
; Remarks:
;
;   Single-line edit control only.
;
;-------------------------------------------------------------------------------
Edit_GetCueBanner(hEdit,p_MaxSize=2048)
    {
    Static EM_GETCUEBANNER:=0x1502  ;-- ECM_FIRST+2
    VarSetCapacity(wText,p_MaxSize,0)
    SendMessage EM_GETCUEBANNER,&wText,p_MaxSize,,ahk_id %hEdit%
    if ErrorLevel  ;-- Cue banner text found
        {
        if not A_IsUnicode
            Edit_Unicode2ANSI(&wText,aText)
    
        Return A_IsUnicode ? wText:aText
        }
    }


;-----------------------------
;
; Function: Edit_GetFirstVisibleLine
;
; Description:
;
;   Returns the zero-based index of the uppermost visible line.  For single-line
;   edit controls, the return value is the zero-based index of the first visible
;   character.
;
;-------------------------------------------------------------------------------
Edit_GetFirstVisibleLine(hEdit)
    {
    Static EM_GETFIRSTVISIBLELINE:=0xCE
    SendMessage EM_GETFIRSTVISIBLELINE,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetLastVisibleLine
;
; Description:
;
;   Returns the zero-based line index of the last visible line on the edit
;   control.
;
; Calls To Other Functions:
;
; * <Edit_GetRect>
; * <Edit_LineFromPos>
;
; Remarks:
;
;   To calculate the total number of visible lines, use the following...
;
;       (start code)
;       Edit_GetLastVisibleLine(hEdit) - Edit_GetFirstVisibleLine(hEdit) + 1
;       (end)
;
;-------------------------------------------------------------------------------
Edit_GetLastVisibleLine(hEdit)
    {
    Edit_GetRect(hEdit,Left,Top,Right,Bottom)
    Return Edit_LineFromPos(hEdit,0,Bottom-1)
    }


;-----------------------------
;
; Function: Edit_GetLimitText
;
; Description:
;
;   Returns the current text limit for the edit control.
;
; Remarks:
;
; - Windows NT+: The maximum text length is 0x7FFFFFFE (2,147,483,646)
;   characters for single-line edit controls and 0xFFFFFFFF (4,294,967,295) for
;   multiline edit controls.  These values are returned if no limit has been set
;   on the edit control.
;
;-------------------------------------------------------------------------------
Edit_GetLimitText(hEdit)
    {
    Static EM_GETLIMITTEXT:=0xD5
    SendMessage EM_GETLIMITTEXT,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetLine
;
; Description:
;
;   Get the text of the desired line from the edit control.
;
; Parameters:
;
;   p_LineIdx - The zero-based index of the line to retrieve. [Optional] Use
;       -1 (the default) to get the current line.  This parameter is ignored if
;       used for a single-line edit control.
;
;   p_Length - Length of the line or length of the text to be extracted.
;       [Optional] Use -1 (the default) to automatically determine the length
;       of the line.
;
; Returns:
;
;   The text of the specified line up to the length (p_Length) specified.  An
;   empty string is returned if the line number specified by p_LineIdx is
;   greater than the number of lines in the Edit control.
;
; Calls To Other Functions:
;
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
;
;-------------------------------------------------------------------------------
Edit_GetLine(hEdit,p_LineIdx=-1,p_Length=-1)
    {
    Static EM_GETLINE:=0xC4
    if (p_LineIdx<0)
        p_LineIdx:=Edit_LineFromChar(hEdit,Edit_LineIndex(hEdit))

    l_TCHARs:=(p_Length<0) ? Edit_LineLength(hEdit,p_LineIdx):p_Length
    if (l_TCHARs=0)
        Return

    ;-- Create and initialize buffer
    nSize:=A_IsUniCode ? l_TCHARs*2:(l_TCHARs=1) ? 2:l_TCHARs
        ;-- Programming note: This is size of the buffer, not necessarily the
        ;   size of the string returned.  Since the first WORD (aka UShort) of
        ;   the buffer is set to the size, in TCHARs, of the buffer, the
        ;   minimum buffer size is 2 bytes.

    VarSetCapacity(l_Text,nSize,0)
    NumPut((l_TCHARs=1) ? 2:l_TCHARs,l_Text,0,"UShort")

    ;-- Get Line
    SendMessage EM_GETLINE,p_LineIdx,&l_Text,,ahk_id %hEdit%
    Return SubStr(l_Text,1,l_TCHARs)
    }


;-----------------------------
;
; Function: Edit_GetLineCount
;
; Description:
;
;   Returns an integer specifying the total number of text lines in a multiline
;   edit control.  If the control has no text, the return value is 1.  The
;   return value will never be less than 1.
;
; Remarks:
;
;   The value returned is for the number of lines in the edit control. Very long
;   lines (>1024) or word wrap may introduce additional lines to the control.
;
;-------------------------------------------------------------------------------
Edit_GetLineCount(hEdit)
    {
    Static EM_GETLINECOUNT:=0xBA
    SendMessage EM_GETLINECOUNT,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetMargins
;
; Description:
;
;   Gets the widths of the left and right margins for the edit control.  If
;   defined, these values are returned in the r_LeftMargin and r_RightMargin
;   variables.
;
; Parameters:
;
;   r_LeftMargin - Left margin, in pixels. [Optional]
;   r_RightMargin - Right margin, in pixels. [Optional]
;
; Returns:
;
;   The edit control's left margin
;
;-------------------------------------------------------------------------------
Edit_GetMargins(hEdit,ByRef r_LeftMargin="",ByRef r_RightMargin="")
    {
    Static EM_GETMARGINS:=0xD4
    SendMessage EM_GETMARGINS,0,0,,ahk_id %hEdit%
    r_LeftMargin :=ErrorLevel&0xFFFF    ;-- LOWORD of result
    r_RightMargin:=ErrorLevel>>16       ;-- HIWORD of result
    Return r_LeftMargin
    }


;-----------------------------
;
; Function: Edit_GetModify
;
; Description:
;
;   Gets the state of the edit control's modification flag.  The flag indicates
;   whether the contents of the edit control have been modified.
;
; Returns:
;
;   TRUE if the edit control has been modified, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_GetModify(hEdit)
    {
    Static EM_GETMODIFY:=0xB8
    SendMessage EM_GETMODIFY,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetPasswordChar
;
; Description:
;
;   Gets the password character that an edit control displays when the user
;   enters text.
;
; Returns:
;
;   The decimal value of the character that is displayed in place of the
;   characters typed by the user.  If a password character has not been set, 0
;   is returned.
;
; Remarks:
;
; - Single-line edit controls only.
;
; - If the return value is an ANSI value (between 1 and 255), the built-in
;   AutoHotkey *Chr* function can be used to convert the value to a character.
;   For example:
;       (start code)
;       Character:=Chr(Edit_GetPasswordChar(hEdit))
;       (end code)
;
; - For most versions of Windows, the default password character decimal value
;   is 9679 (black circle).
;
; Requirements:
;
;   Windows 2000+
;
;-------------------------------------------------------------------------------
Edit_GetPasswordChar(hEdit)
    {
    Static EM_GETPASSWORDCHAR:=0xD2
    Return DllCall("SendMessageW","UInt",hEdit,"UInt",EM_GETPASSWORDCHAR,"UInt",0,"UInt",0)
    }


;-----------------------------
;
; Function: Edit_GetRect
;
; Description:
;
;   Gets the formatting rectangle of the edit control.
;
; Parameters:
;
;   r_Left..r_Bottom - Output variables. [Optional]
;
; Returns:
;
;   Space separated rectangle.
;
;-------------------------------------------------------------------------------
Edit_GetRect(hEdit,ByRef r_Left="",ByRef r_Top="",ByRef r_Right="",ByRef r_Bottom="")
    {
    Static EM_GETRECT:=0xB2
    VarSetCapacity(RECT,16,0)
    SendMessage EM_GETRECT,0,&RECT,,ahk_id %hEdit%
    r_Left  :=NumGet(RECT,0,"Int")
    r_Top   :=NumGet(RECT,4,"Int")
    r_Right :=NumGet(RECT,8,"Int")
    r_Bottom:=NumGet(RECT,12,"Int")
    Return r_Left . A_Space . r_Top . A_Space . r_Right . A_Space . r_Bottom
    }


;-----------------------------
;
; Function: Edit_GetSel
;
; Description:
;
;   Gets the starting and ending character positions of the current selection in
;   the edit control.  If defined, these values are returned in the
;   r_StartSelPos and r_EndSelPos variables.
;
; Parameters:
;
;   r_StartSelPos - Starting position of the selection. [Optional]
;   r_EndSelPos - Ending position of the selection. [Optional]
;
; Returns:
;
;   Starting position of the selection.
;
;-------------------------------------------------------------------------------
Edit_GetSel(hEdit,ByRef r_StartSelPos="",ByRef r_EndSelPos="")
    {
    Static EM_GETSEL:=0xB0
    VarSetCapacity(l_StartSelPos,4,0)
    VarSetCapacity(l_EndSelPos,4,0)
    SendMessage EM_GETSEL,&l_StartSelPos,&l_EndSelPos,,ahk_id %hEdit%
    r_StartSelPos:=NumGet(l_StartSelPos)
    r_EndSelPos  :=NumGet(l_EndSelPos)
    Return r_StartSelPos
    }


;-----------------------------
;
; Function: Edit_GetSelText
;
; Description:
;
;   Returns the currently selected text (if any).
;
; Calls To Other Functions:
;
; * <Edit_GetLine>
; * <Edit_GetSel>
; * <Edit_GetText>
; * <Edit_LineFromChar>
; * <Edit_LineIndex>
; * <Edit_LineLength>
;
; Remarks:
;
;   Since the edit control does not support the EM_GETSELTEXT message, the
;   EM_GETLINE (if the selection is on one line) and the WM_GETTEXT messages are
;   used instead.
;
;-------------------------------------------------------------------------------
Edit_GetSelText(hEdit)
    {
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    if (l_StartSelPos=l_EndSelPos)
        Return

    ;-- Get line indexes of the selection
    l_FirstSelectedLine:=Edit_LineFromChar(hEdit,l_StartSelPos)
    l_LastSelectedLine :=Edit_LineFromChar(hEdit,l_EndSelPos)

    ;-- Get selected text
    l_FirstPos:=Edit_LineIndex(hEdit,l_FirstSelectedLine)
     if (l_FirstSelectedLine=l_LastSelectedLine)
    and (l_EndSelPos<=l_FirstPos+Edit_LineLength(hEdit,l_FirstSelectedLine))
        Return SubStr(Edit_GetLine(hEdit,l_FirstSelectedLine,l_EndSelPos-l_FirstPos),l_StartSelPos-l_FirstPos+1)
     else
        Return SubStr(Edit_GetText(hEdit,l_EndSelPos),l_StartSelPos+1)
    }


;-----------------------------
;
; Function: Edit_GetText
;
; Description:
;
;   Returns all text from the control up to p_Length length.  If p_Length=-1
;   (the default), all text is returned.
;
; Calls To Other Functions:
;
; * <Edit_GetTextLength>
;
; Remarks:
;
;   This function is similar to the AutoHotkey *GUIControlGet* command (for AHK
;   GUIs) and the *ControlGetText* command except that end-of-line (EOL)
;   characters from the retrieved text are not automatically converted
;   (CR+LF to LF).  If needed, use <Edit_Convert2Unix> to convert the text to
;   the AutoHotkey text format.
;
;-------------------------------------------------------------------------------
Edit_GetText(hEdit,p_Length=-1)
    {
    Static WM_GETTEXT:=0xD
    if (p_Length<0)
        p_Length:=Edit_GetTextLength(hEdit)

    VarSetCapacity(l_Text,p_Length*(A_IsUnicode ? 2:1)+1,0)
    SendMessage WM_GETTEXT,p_Length+1,&l_Text,,ahk_id %hEdit%
    return l_Text
    }


;-----------------------------
;
; Function: Edit_GetTextLength
;
; Description:
;
;   Returns the length, in characters, of the text in the edit control.
;
;-------------------------------------------------------------------------------
Edit_GetTextLength(hEdit)
    {
    Static WM_GETTEXTLENGTH:=0xE
    SendMessage WM_GETTEXTLENGTH,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_GetTextRange
;
; Description:
;
;   Get a range of characters.
;
; Parameters:
;
;   p_Min - Character position index immediately preceding the first character
;       in the range.
;
;   p_Max - Character position immediately following the last character in the
;       range.  Set to -1 to indicate the end of the text.
;
; Calls To Other Functions:
;
; * <Edit_GetText>
;
; Remarks:
;
;   Since the edit control does not support the EM_GETTEXTRANGE message,
;   <Edit_GetText> (WM_GETTEXT message) is used to collect the desired range of
;   of characters.
;
;-------------------------------------------------------------------------------
Edit_GetTextRange(hEdit,p_Min=0,p_Max=-1)
    {
    Return SubStr(Edit_GetText(hEdit,p_Max),p_Min+1)
    }


;-----------------------------
;
; Function: Edit_HideBalloonTip
;
; Description:
;
;   Hides any balloon tip associated with an edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   This function is usually unnecessary.  A balloon tip will usually auto-hide
;   after short period of time (5 to 15 seconds).  In addition, the balloon tip
;   will auto-hide if the contents of the control are changed or if focus is
;   moved to another control.
;
; Requirements:
;
;   Windows XP+
;
;-------------------------------------------------------------------------------
Edit_HideBalloonTip(hEdit)
    {
    Static EM_HIDEBALLOONTIP:=0x1504
    SendMessage EM_HIDEBALLOONTIP,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_IsMultiline
;
; Description:
;
;   Returns TRUE if the edit control is multiline, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_IsMultiline(hEdit)
    {
    Static ES_MULTILINE:=0x4
    Return Edit_IsStyle(hEdit,ES_MULTILINE)
    }


;-----------------------------
;
; Function: Edit_IsReadOnly
;
; Description:
;
;   Returns TRUE if the ES_READONLY style has been set, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_IsReadOnly(hEdit)
    {
    Static ES_READONLY:=0x800
    Return Edit_IsStyle(hEdit,ES_READONLY)
    }


;-----------------------------
;
; Function: Edit_IsStyle
;
; Description:
;
;   Returns TRUE if the specified style has been set, otherwise FALSE.
;
; Parameters:
;
;   p_Style - Style of the edit control.
;
;   Some common edit control styles...
;
;   (start code)
;   ES_LEFT       :=0x0         ;-- Can't actually check this style.  It's the lack of ES_CENTER or ES_RIGHT.
;   ES_CENTER     :=0x1
;   ES_RIGHT      :=0x2
;   ES_MULTILINE  :=0x4
;   ES_UPPERCASE  :=0x8
;   ES_LOWERCASE  :=0x10
;   ES_PASSWORD   :=0x20        ;-- Single-line edit control only
;   ES_AUTOVSCROLL:=0x40
;   ES_AUTOHSCROLL:=0x80
;   ES_NOHIDESEL  :=0x100
;   ES_COMBO      :=0x200
;   ES_OEMCONVERT :=0x400
;   ES_READONLY   :=0x800
;   ES_WANTRETURN :=0x1000
;   ES_NUMBER     :=0x2000
;   WS_TABSTOP    :=0x10000
;   WS_HSCROLL    :=0x100000
;   WS_VSCROLL    :=0x200000
;   (end)
;
;-------------------------------------------------------------------------------
Edit_IsStyle(hEdit,p_Style)
    {
    Static GWL_STYLE:=-16
;;;;;    l_Style:=DllCall("GetWindowLong","UInt",hEdit,"Int",GWL_STYLE)
    ControlGet l_Style,Style,,,ahk_id %hEdit%
    Return l_Style & p_Style ? True:False
    }


;-----------------------------
;
; Function: Edit_SetStyle
;
; Description:
;
;   Adds, removes, or toggles a style for an edit control.
;
;
; Parameters:
;
;   p_Style - Style to set.
;
;   p_Option - Use "+" (the default) to add, "-" to remove, and "^" to toggle.
;
; Returns:
;
;   TRUE if the request completed successfully, otherwise FALSE.
;
; Remarks:
;
;   Styles that can be modified after the edit control has been created include
;   the following:
;
;   (start code)
;   ES_UPPERCASE  :=0x8
;   ES_LOWERCASE  :=0x10
;   ES_PASSWORD   :=0x20    ;-- Use the Edit_SetPasswordChar function
;   ES_OEMCONVERT :=0x400
;   ES_READONLY   :=0x800   ;-- Use the Edit_SetReadOnly function
;   ES_WANTRETURN :=0x1000
;   ES_NUMBER     :=0x2000
;   (end)
;
;   Use <Edit_IsStyle> to determine if a style is currently set.
;
;-------------------------------------------------------------------------------
Edit_SetStyle(hEdit,p_Style,p_Option="+")
    {
    Control Style,%p_Option%%p_Style%,,ahk_id %hEdit%
    Return ErrorLevel ? False:True
    }


;-----------------------------
;
; Function: Edit_LineFromChar
;
; Description:
;
;   Gets the index of the line that contains the specified character index.
;
; Parameters:
;
;   p_CharPos - The character index of the character contained in the line
;       whose number is to be retrieved. [Optional] If –1 (the default), the
;       function retrieves either the line number of the current line (the line
;       containing the caret) or, if there is a selection, the line number of
;       the line containing the beginning of the selection.
;
; Returns:
;
;   The zero-based line number of the line containing the character index
;   specified by p_CharPos.
;
;-------------------------------------------------------------------------------
Edit_LineFromChar(hEdit,p_CharPos=-1)
    {
    Static EM_LINEFROMCHAR:=0xC9
    SendMessage EM_LINEFROMCHAR,p_CharPos,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_LineFromPos
;
; Description:
;
;   This function is the same as <Edit_CharFromPos> except the line index
;   (r_LineIdx) is returned.
;
;-------------------------------------------------------------------------------
Edit_LineFromPos(hEdit,X,Y,ByRef r_CharPos="",ByRef r_LineIdx="")
    {
    Edit_CharFromPos(hEdit,X,Y,r_CharPos,r_LineIdx)
    Return r_LineIdx
    }


;-----------------------------
;
; Function: Edit_LineIndex
;
; Description:
;
;   Gets the character index of the first character of a specified line.
;
; Parameters:
;
;   p_LineIdx - Zero-based line number. [Optional] Use -1 (the default) for the
;       current line.
;
; Returns:
;
;   The character index of the specified line or -1 if the specified line is
;   greater than the total number of lines in the edit control.
;
;-------------------------------------------------------------------------------
Edit_LineIndex(hEdit,p_LineIdx=-1)
    {
    Static EM_LINEINDEX:=0xBB
    SendMessage EM_LINEINDEX,p_LineIdx,0,,ahk_id %hEdit%
    Return ErrorLevel<<32>>32  ;-- Convert UInt to Int
    }


;-----------------------------
;
; Function: Edit_LineLength
;
; Description:
;
;   Gets the length of a line.
;
; Parameters:
;
;   p_LineIdx - The zero-based line index of the desired line.  Use -1
;       (the default) for the current line.
;
; Returns:
;
;   The length, in characters, of the specified line.  If p_LineIndex is greater
;   than the total number of lines in the edit control, the length of the last
;   (or only) line is returned.
;
; Calls To Other Functions:
;
; * <Edit_GetTextLength>
; * <Edit_LineIndex>
;
;-------------------------------------------------------------------------------
Edit_LineLength(hEdit,p_LineIdx=-1)
    {
    Static EM_LINELENGTH:=0xC1
    l_CharPos:=Edit_LineIndex(hEdit,p_LineIdx)
    if (l_CharPos<0)  ;-- Invalid p_LineIdx
        l_CharPos:=Edit_LineIndex(hEdit,Edit_GetTextLength(hEdit)-1)

    SendMessage EM_LINELENGTH,l_CharPos,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_LineScroll
;
; Description:
;
;   Scrolls the text in the edit control for the current file.
;
; Parameters:
;
;   xScroll - The number of characters to scroll horizontally.  Use a negative
;       number to scroll to the left and a positive number to scroll to the
;       right.
;
;   yScroll - The number of lines to scroll vertically.  Use a negative number
;       to scroll up and a positive number to scroll down.
;
; Returns:
;
;   TRUE if sent to a multiline edit control, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_LineScroll(hEdit,xScroll=0,yScroll=0)
    {
    Static EM_LINESCROLL:=0xB6
    SendMessage EM_LINESCROLL,xScroll,yScroll,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_LoadFile
;
; Description:
;
;   Load the contents of a file to the edit control.
;
; Parameters:
;
;   p_FileName - The full path and name of the file.
;
;   p_Convert2DOS - If TRUE, the text will be converted from Unix, DOS/Unix mix,
;       or Mac format, to DOS format before it is loaded to the edit control.
;       [Optional]
;
;   r_FileFormat - Contains the file format variable. [Optional]  This variable
;       is set to the file format of loaded file - "DOS", "Unix", or "Mac".
;       This information is useful if the contents of the edit control will be
;       be converted back to the original file format when the file is saved.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_Convert2DOS>
; * <Edit_SetText>
;
; Remarks:
;
;   This request will replace the entire edit control with the contents of the
;   the requested file.  Consequently, the Undo buffer is flushed.
;
;-------------------------------------------------------------------------------
Edit_LoadFile(hEdit,p_FileName,p_Convert2DOS=False,ByRef r_FileFormat="")
    {
    IfNotExist %p_FileName%
        {
        outputdebug Function: %A_ThiSFunc% - File "%p_FileName%" not found
        Return False
        }

    ;-- Load contents of file into variable
    FileRead l_Text,%p_FileName%
    if ErrorLevel
        {
        outputdebug Function: %A_ThiSFunc% - Unable to read from "%p_FileName%"
        Return False
        }

    ;-- Determine file format
    if l_Text Contains `r`n
        r_FileFormat:="DOS"
     else
        if l_Text Contains `n
            r_FileFormat:="UNIX"
         else
            if l_Text Contains `r
                r_FileFormat:="MAC"
             else
                r_FileFormat:="DOS"

    ;-- Convert file format?
    if p_Convert2DOS
        l_Text:=Edit_Convert2DOS(l_Text)

    ;-- Load text to edit control
    Return Edit_SetText(hEdit,l_Text)
    }


;-----------------------------
;
; Function: Edit_Paste
;
; Description:
;
;   Copies the current content of the clipboard to the edit control at the
;   current caret position.  Data is inserted only if the clipboard contains
;   data in CF_TEXT format.
;
;-------------------------------------------------------------------------------
Edit_Paste(hEdit)
    {
    Static WM_PASTE:=0x302
    SendMessage WM_PASTE,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_PosFromChar
;
; Description:
;
;   Gets the client area coordinates of a specified character in the edit
;   control.
;
; Parameters:
;
;   p_CharPos - The zero-based index of the character.
;
;   X, Y - These parameters, which must contain valid variable names, are used
;       to return the x/y-coordinates of a point in the Edit control's client
;       relative to the upper-left corner of the client area.
;
; Remarks:
;
;   If p_CharPos is greater than the index of the last character in the
;   control, the returned coordinates are of the position just past the last
;   character of the control.
;
;-------------------------------------------------------------------------------
Edit_PosFromChar(hEdit,p_CharPos,ByRef X,ByRef Y)
    {
    Static EM_POSFROMCHAR:=0xD6
    SendMessage EM_POSFROMCHAR,p_CharPos,0,,ahk_id %hEdit%
    X:=(ErrorLevel & 0xFFFF)<<48>>48
        ;-- LOWORD of result and converted from UShort to Short
    Y:=(ErrorLevel>>16)<<48>>48
        ;-- HIWORD of result and converted from UShort to Short
    }


;-----------------------------
;
; Function: Edit_ReplaceSel
;
; Description:
;
;   Replaces the selected text with the specified text.  If there is no
;   selection, the replacement text is inserted at the caret.
;
; Parameters:
;
;   p_Text - Text to replace selection with.
;   p_CanUndo - If TRUE (the default), replace can be undone.
;
;-------------------------------------------------------------------------------
Edit_ReplaceSel(hEdit,p_Text="",p_CanUndo=True)
    {
    Static EM_REPLACESEL:=0xC2
    SendMessage EM_REPLACESEL,p_CanUndo,&p_Text,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SaveFile
;
; Description:
;
;   Save the contents of the edit control to a file.  If the file does not
;   exist, it will be created.
;
; Parameters:
;
;   p_FileName - The full path and name of the file.
;
;   p_Convert - Convert file format. [Optional] Set to "M" or "Mac" to convert
;       to Mac.  Set to "U" or "Unix" to convert to Unix.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_Convert2Mac>
; * <Edit_Convert2Unix>
; * <Edit_GetText>
;
; Remarks:
;
;   To get around a rare FileAppend bug in AutoHotkey Basic, this function will
;   retry to save the file once (after a short sleep), if the first attempt
;   fails.
;
;-------------------------------------------------------------------------------
Edit_SaveFile(hEdit,p_FileName,p_Convert="")
    {
    ;-- Delete if file exists
    IfExist %p_FileName%
        {
        FileDelete %p_FileName%
        if ErrorLevel
            {
            outputdebug Function: %A_ThisFunc% - Unable to delete "%p_FileName%"
            Return False
            }
        }

    ;-- Get text
    l_Text:=Edit_GetText(hEdit)

    ;-- Convert file format
    if p_Convert
        {
        StringUpper,p_Convert,p_Convert,T  ;-- Just in case StringCaseSense is On
        if p_Convert in U,Unix
            l_Text:=Edit_Convert2Unix(l_Text)
         else
            if p_Convert in M,Mac
                l_Text:=Edit_Convert2Mac(l_Text)
        }

    ;-- Save it
    Loop 2
        {
        FileAppend %l_Text%,*%p_FileName%  ;-- Save in binary mode
        if ErrorLevel
            {
            outputdebug Function: %A_ThisFunc% - Unable to save to "%p_FileName%"
            if (A_Index=2)
                Return False

            outputdebug ...will try to save one more time after a short sleep.
            Sleep 50
                ;-- ##### Not sure how much time to sleep.  Yes, sleep is needed.

            Continue
            }

        if (A_Index=2)
            outputdebug ...Save successful!

        Break
        }

    Return True
    }


;-----------------------------
;
; Function: Edit_SetCueBanner
;
; Description:
;
;   Sets the textual cue, or tip, that is displayed by the edit control to
;   prompt the user for information.
;
; Parameters:
;
;   p_Text - Cue banner text.
;
;   p_ShowWhenFocused - [Vista+] Set to TRUE to show the cue banner even if the
;       edit control has focus.  The default is FALSE (don't show when the edit
;       control has focus).
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   Single-line edit control only.
;
; Requirements:
;
;   Windows XP+
;
; Calls To Other Functions:
;
; * <Edit_ANSI2Unicode>
;
;-------------------------------------------------------------------------------
Edit_SetCueBanner(hEdit,p_Text,p_ShowWhenFocused=False)
    {
    Static EM_SETCUEBANNER:=0x1501  ;-- ECM_FIRST+1
    if A_IsUnicode
        wText:=p_Text
     else
        Edit_ANSI2Unicode(&p_Text,wText)

    SendMessage EM_SETCUEBANNER,p_ShowWhenFocused,&wText,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_Scroll
;
; Description:
;
;   Scrolls the text vertically in the edit control.
;
; Parameters:
;
;   p_Pages - The number of pages to scroll.  Use a negative number to scroll up
;       and a positive number to scroll down.
;
;   p_Lines - The number of lines to scroll.  Use a negative number to scroll up
;       and a positive number to scroll down.
;
; Returns:
;
;   The number of lines that the command scrolls. The value will be negative if
;   scrolling up and positive if scrolling down.
;
;-------------------------------------------------------------------------------
Edit_Scroll(hEdit,p_Pages=0,p_Lines=0)
    {
    Static EM_SCROLL  :=0xB5
          ,SB_LINEUP  :=0x0     ;-- Scroll up one line
          ,SB_LINEDOWN:=0x1     ;-- Scroll down one line
          ,SB_PAGEUP  :=0x2     ;-- Scroll up one page
          ,SB_PAGEDOWN:=0x3     ;-- Scroll down one page

    ;-- Initialize
    l_ScrollLines:=0

    ;-- Pages
    Loop % Abs(p_Pages)
        {
        SendMessage EM_SCROLL,(p_Pages>0) ? SB_PAGEDOWN:SB_PAGEUP,0,,ahk_id %hEdit%
        if not ErrorLevel
            Break

        l_ScrollLines:=l_ScrollLines+((ErrorLevel & 0xFFFF)<<48>>48)
            ;-- LOWORD of result and converted from UShort to Short
        }

    ;-- Lines
    Loop % Abs(p_Lines)
        {
        SendMessage EM_SCROLL,(p_Lines>0) ? SB_LINEDOWN:SB_LINEUP,0,,ahk_id %hEdit%
        if not ErrorLevel
            Break

        l_ScrollLines:=l_ScrollLines+((ErrorLevel & 0xFFFF)<<48>>48)
            ;-- LOWORD of result and converted from UShort to Short
        }

    Return l_ScrollLines
    }


;-----------------------------
;
; Function: Edit_ScrollCaret
;
; Description:
;
;   Scrolls the text vertically in the edit control.
;
; Parameters:
;
;   p_Pages - The number of pages to scroll.  Use a negative number to scroll up
;       and a positive number to scroll down.
;
;   p_Lines - The number of lines to scroll.  Use a negative number to scroll up
;       and a positive number to scroll down.
;
; Returns:
;
;   The number of lines that the command scrolls. The value will be negative if
;   scrolling up and positive if scrolling down.
;
;-------------------------------------------------------------------------------
Edit_ScrollCaret(hEdit)
    {
    Static EM_SCROLLCARET:=0xB7
    SendMessage EM_SCROLLCARET,0,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetLimitText
;
; Description:
;
;   Sets the text limit of the edit control.
;
; Parameters:
;
;   p_Limit - The maximum number of characters the user can enter.
;       Windows NT+: If this parameter is zero, the text length is set to
;       0x7FFFFFFE (2,147,483,646) characters for single-line edit controls and
;       0xFFFFFFFF (4,294,967,295) for multiline edit controls.
;
; Remarks:
;
; - This message limits only the text the user can enter. It does not affect any
;   text already in the edit control when the message is sent, nor does it
;   affect the length of the text copied to the edit control by the WM_SETTEXT
;   message. For more information:
;
;       <http://msdn.microsoft.com/en-us/library/bb761607(VS.85).aspx>
;
; - For AutoHotkey GUI's, use the +Limitnn and -Limit options.
;
; - Warning: Although this message can be sent to any edit control, not all
;   programs will respond well to a limit change.
;
;-------------------------------------------------------------------------------
Edit_SetLimitText(hEdit,p_Limit)
    {
    Static EM_LIMITTEXT:=0xC5
    SendMessage EM_LIMITTEXT,p_Limit,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetMargins
;
; Description:
;
;   Sets the width of the left and/or right margin (in pixels) for the edit
;   control. The message automatically redraws the control to reflect the new
;   margins.
;
; Parameters:
;
;   p_LeftMargin - Left margin, in pixels. If blank, the left margin is not set.
;       Specify the EC_USEFONTINFO value (0xFFFF or 65535) to set the left
;       margin to a narrow width calculated using the text metrics of the
;       control's current font. If no font has been set for the control, the
;       margin is set to zero.
;
;   p_RightMargin - Right margin, in pixels.  If blank, the right margin is not
;       set.  Specify the EC_USEFONTINFO value (0xFFFF or 65535) to set the
;       right margin to a narrow width calculated using the text metrics of the
;       control's current font.  If no font has been set for the control, the
;       margin is set to zero.
;
;-------------------------------------------------------------------------------
Edit_SetMargins(hEdit,p_LeftMargin="",p_RightMargin="")
    {
    Static EM_SETMARGINS :=0xD3
          ,EC_LEFTMARGIN :=0x1
          ,EC_RIGHTMARGIN:=0x2
          ,EC_USEFONTINFO:=0xFFFF

    l_Margins:=0
    l_Flags  :=0
    if p_LeftMargin is Integer
        {
        l_Flags  |=EC_LEFTMARGIN
        l_Margins|=p_LeftMargin       ;-- LOWORD
        }

    if p_RightMargin is Integer
        {
        l_Flags  |=EC_RIGHTMARGIN
        l_Margins|=p_RightMargin<<16  ;-- HIWORD
        }

    if l_Flags
        SendMessage EM_SETMARGINS,l_Flags,l_Margins,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetModify
;
; Description:
;
;   Sets or clears the modification flag for the edit control. The modification
;   flag indicates whether the text within the control has been modified.
;
; Parameters:
;
;   p_Flag - Set to TRUE to set the modification flag. Set to FALSE to clear the
;       modification flag.
;
;-------------------------------------------------------------------------------
Edit_SetModify(hEdit,p_Flag)
    {
    Static EM_SETMODIFY:=0xB9
    SendMessage EM_SETMODIFY,p_Flag,0,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetPasswordChar
;
; Description:
;
;   Sets or removes the password character for a single-line edit control.
;
; Parameters:
;
;   p_CharValue - The decimal value of the character that is displayed in place
;       of the characters typed by the user. [Optional] The default is an 9679
;       (black circle).  Set to 0 (null) to remove the password character.
;
; Returns:
;
;   Documented: This message does not return a value.  Undocumented and/or does
;   not apply to all OS versions: Returns TRUE if successful or "FAIL" if
;   unsuccessful.
;
; Remarks:
;
; - The code for this function extracted from:
;   http://www.autohotkey.com/forum/viewtopic.php?p=392973#392973
;   Author: Unknown
;
; - Use <Edit_IsStyle> to determine if the ES_PASSWORD style has been set.
;
; Observations:
;
; - On Windows 2000+, the ES_Password style cannot be removed once added unless
;   the request is made from the same process that created the control.
;
;-------------------------------------------------------------------------------
Edit_SetPasswordChar(hEdit,p_CharValue=9679)
    {
    Static EM_SETPASSWORDCHAR:=0xCC
    l_RC:=DllCall("SendMessageW","UInt",hEdit,"UInt",EM_SETPASSWORDCHAR,"UInt",p_CharValue,"UInt",0)
    WinSet Redraw,,ahk_id %hEdit%  ;-- Force style change to show
    Return l_RC
    }


;-----------------------------
;
; Function: Edit_SetReadOnly
;
; Description:
;
;   Sets or removes the read-only style (ES_READONLY) of the edit control.
;
; Parameters:
;
;   p_Flag - Set to TRUE to add the ES_READONLY style.  Set to FALSE to remove
;       the ES_READONLY style.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
;   For AutoHotkey GUIs, this is same as using the +ReadOnly or -ReadOnly
;   option when creating the Edit control or using the GUIControl command after
;   the edit control has been created.  For example:
;
;       (start code)
;       GUIControl +ReadOnly,Edit1
;       (end code)
;
;-------------------------------------------------------------------------------
Edit_SetReadOnly(hEdit,p_Flag)
    {
    Static EM_SETREADONLY:=0xCF
    SendMessage EM_SETREADONLY,p_Flag,0,,ahk_id %hEdit%
    Return ErrorLevel ? True:False
    }


;-----------------------------
;
; Function: Edit_SetRect
;
; Description:
;
;   Sets the formatting rectangle of a multiline edit control. The formatting
;   rectangle is the limiting rectangle into which the control draws the text.
;   The limiting rectangle is independent of the size of the edit control
;   window.
;
; Parameters:
;
;   p_Left..p_Bottom - Coordinates.
;
; Remarks:
;
;   Advanced feature. For additional information, see the following...
;
;       <http://msdn.microsoft.com/en-us/library/bb761657(VS.85).aspx>
;
;-------------------------------------------------------------------------------
Edit_SetRect(hEdit,p_Left,p_Top,p_Right,p_Bottom)
    {
    Static EM_SETRECT:=0xB3
    VarSetCapacity(RECT,16,0)
    NumPut(p_Left,  RECT,0,"Int")
    NumPut(p_Top,   RECT,4,"Int")
    NumPut(p_Right, RECT,8,"Int")
    NumPut(p_Bottom,RECT,12,"Int")
    SendMessage EM_SETRECT,0,&RECT,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_SetTabStops
;
; Description:
;
;   Sets the tab stops in a multiline edit control. When text is copied to the
;   control, any tab character in the text causes space to be generated up to
;   the next tab stop.
;
; Parameters:
;
;   p_NbrOfTabStops - Number of tab stops. [Optional] Set to 0 (the default) to
;       set the tab stops to the system default.  Set to 1 to have all tab stops
;       set to the value of the p_DTU parameter or 32 if p_DTU is not defined.
;       Any value greater than 1 will set that number of tab stops.
;
;   p_DTU - Dialog Template Units. [Optional] If p_NbrOfTabStops=0, this
;       parameter is ignored.  If this parameter contains a single value
;       (Ex: 21), all tab stops will be set to a factor of this value
;       (Ex: 21, 42, 63, etc.).  Otherwise, this parameter should contain values
;       for all requested tab stops each separated by a comma ","
;       (Ex: "20,45,70,125").
;
; Returns:
;
;   TRUE if all the tabs are set, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_SetTabStops(hEdit,p_NbrOfTabStops=0,p_DTU=32)
    {
    Static EM_SETTABSTOPS:=0xCB
    VarSetCapacity(l_TabStops,p_NbrOfTabStops*4,0)
    if p_DTU contains ,,
        {
        Loop Parse,p_DTU,`,,%A_Space%
            if (A_Index<=p_NbrOfTabStops)
                Numput(A_LoopField+0,l_TabStops,(A_Index-1)*4,"UInt")
        }
     else
        Loop %p_NbrOfTabStops%
            NumPut(p_DTU*A_Index,l_TabStops,(A_Index-1)*4,"UInt")

    SendMessage EM_SETTABSTOPS,p_NbrOfTabStops,&l_TabStops,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_SetText
;
; Description:
;
;   Set the text of the edit control.
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Remarks:
;
; - The system automatically clears the modification flag whenever an edit
;   control receives a WM_SETTEXT message.
;
; - The system automatically resets the undo flag whenever an edit control
;   receives a WM_SETTEXT message.  Use <Edit_SetSel> (select all) and
;   <Edit_ReplaceSel> to populate the control if undo is desired.
;
; - This function is similar to the AutoHotkey *ControlSetText* command except
;   there is no delay after the command has executed.
;
;-------------------------------------------------------------------------------
Edit_SetText(hEdit,p_Text)
    {
    Static WM_SETTEXT:=0xC
    SendMessage WM_SETTEXT,0,&p_Text,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_SetSel
;
; Description:
;
;   Selects a range of characters.
;
; Parameters:
;
;   p_StartSelPos - Starting character position of the selection. If set to -1,
;       the current selection (if any) will be deselected.
;
;   p_EndSelPos - Ending character position of the selection. Set to -1 to use
;       the position of the last character in the control.
;
;-------------------------------------------------------------------------------
Edit_SetSel(hEdit,p_StartSelPos=0,p_EndSelPos=-1)
    {
    Static EM_SETSEL:=0x0B1
    SendMessage EM_SETSEL,p_StartSelPos,p_EndSelPos,,ahk_id %hEdit%
    }


;-----------------------------
;
; Function: Edit_ShowBalloonTip
;
; Description:
;
;   Displays a balloon tip associated with an edit control.
;
; Parameters:
;
;   p_Title - Balloon tip title.  Required but can be empty/null.
;
;   p_Text - Balloon tip text.
;
;   p_Icon - Type of icon to associate with the ballon tip. [Optional]  The
;       default is 0 (No icon).
;
; Returns:
;
;   TRUE if successful, otherwise FALSE.
;
; Requirements:
;
;   Windows XP+
;
; Calls To Other Functions:
;
; * <Edit_ANSI2Unicode>
;
; Remarks:
;
; - Calling this function will move focus to the designated edit control.
;
; - A balloon tip will not show if the "EnableBalloonTips" registry key is
;       disabled (set to 0).  The key can be found here:
;           HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\
;
; - The balloon tip icon (if specified) will not be displayed unless a title
;       (p_Title) is also specified.
;
;-------------------------------------------------------------------------------
Edit_ShowBalloonTip(hEdit,p_Title,p_Text,p_Icon=0)
    {
    Static EM_SHOWBALLOONTIP:=0x1503

          ;-- p_Icon values
          ,TTI_NONE         :=0
          ,TTI_INFO         :=1
          ,TTI_WARNING      :=2
          ,TTI_ERROR        :=3

          ;-- p_Icon values (Vista+ only)
          ,TTI_INFO_LARGE   :=4
          ,TTI_WARNING_LARGE:=5
          ,TTI_ERROR_LARGE  :=6

    ;-- Workaround for AutoHotkey Basic
    PtrSize:=A_PtrSize ? A_PtrSize:4
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- If necessary, convert title and text to Unicode
    if A_IsUnicode
        {
        wTitle:=p_Title
        wText :=p_Text
        }
     else
        {
        Edit_ANSI2Unicode(&p_Title,wTitle)
        Edit_ANSI2Unicode(&p_Text,wText)
        }

    ;-- Define and populate EDITBALLOONTIP Structure
    VarSetCapacity(EDITBALLOONTIP,4+PtrSize+PtrSize+4)
    NumPut(16,     EDITBALLOONTIP,0,"Int")
    NumPut(&wTitle,EDITBALLOONTIP,4,PtrType)
    NumPut(&wText, EDITBALLOONTIP,4+PtrSize,PtrType)
    NumPut(p_Icon, EDITBALLOONTIP,4+PtrSize+PtrSize,"Int")

    ;-- Show it
    SendMessage EM_SHOWBALLOONTIP,0,&EDITBALLOONTIP,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_TextIsSelected
;
; Description:
;
;   Returns TRUE if text is selected, otherwise FALSE.
;
; Calls To Other Functions:
;
; * <Edit_GetSel>
;
;-------------------------------------------------------------------------------
Edit_TextIsSelected(hEdit)
    {
    Edit_GetSel(hEdit,l_StartSelPos,l_EndSelPos)
    Return (l_StartSelPos<>l_EndSelPos)
    }


;-----------------------------
;
; Function: Edit_Undo
;
; Description:
;
;   Undo the last operation.
;
; Returns:
;
;   For a single-line edit control, the return value is always TRUE.  For a
;   multiline edit control, the return value is TRUE if the undo operation is
;   successful, otherwise FALSE.
;
;-------------------------------------------------------------------------------
Edit_Undo(hEdit)
    {
    Static EM_UNDO:=0xC7
    SendMessage EM_UNDO,0,0,,ahk_id %hEdit%
    Return ErrorLevel
    }


;-----------------------------
;
; Function: Edit_Unicode2ANSI
;
; Description:
;
;   Maps a UTF-16 (wide character) string to a character string (ANSI).
;
; Type:
;
;   Internal function.  Subject to change.  Do not use.
;
; Parameters:
;
;   lpWideCharStr - Address to UTF-16 (wide character) string.
;
;   MultiByteStr - Variable to store character string (ANSI).
;
; Remarks:
;
;   Function adapted from the COM library. Original author: *Sean*
;
;-------------------------------------------------------------------------------
Edit_Unicode2ANSI(lpWideCharStr,ByRef MultiByteStr)
    {
    Static CP_ACP:=0    ;-- The system default Windows ANSI code page.

    ;-- Workaround for AutoHotkey Basic
    PtrType:=(A_PtrSize=8) ? "Ptr":"UInt"

    ;-- Collect size
    nSize:=DllCall("WideCharToMultiByte"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT, in]
            ,"UInt",0
                ;-- dwFlags [DWORD, in]
            ,PtrType,lpWideCharStr
                ;-- lpWideCharStr [LPCWSTR, in].  Pointer to Unicode string.
            ,"Int",-1
                ;-- cchWideChar [Int, in].  Size, in characters, of the string
                ;   indicated by lpWideCharStr. -1=String is null terminated.
            ,PtrType,0
                ;-- lpMultiByteStr [LPSTR, out].  Pointer to a buffer that
                ;   receives the converted string. Not used/specified here.
            ,"Int",0
                ;-- cbMultiByte [Int, in].  Size, in bytes, of the buffer
                ;   indicated by lpMultiByteStr. When set to 0, the function
                ;   returns the required buffer size for lpMultiByteStr.
            ,PtrType,0
                ;-- lpDefaultChar [LPCSTR,in].  Not used.
            ,PtrType,0)
                ;-- lpUsedDefaultChar [LPBOOL, out].  Not used.

    ;-- Convert to ANSI
    VarSetCapacity(MultiByteStr,nSize,0)  ;-- Size includes terminating null
    DllCall("WideCharToMultiByte"
            ,"UInt",CP_ACP
                ;-- CodePage [UINT, in]
            ,"UInt",0
                ;-- dwFlags [DWORD, in]
            ,PtrType,lpWideCharStr
                ;-- lpWideCharStr [LPCWSTR, in].  Pointer to Unicode string.
            ,"Int",nSize
                ;-- cchWideChar [Int, in]. Size, in characters, of the string
                ;   indicated by lpWideCharStr. For this function, nSize
                ;   includes the terminating null if found.
            ,"Str",MultiByteStr
                ;-- lpMultiByteStr [LPSTR, out].  Pointer to a buffer that
                ;   receives the converted string.
            ,"Int",nSize
                ;-- cbMultiByte [Int, in].  Size, in bytes, of the buffer
                ;   indicated by lpMultiByteStr.
            ,PtrType,0
                ;-- lpDefaultChar [LPCSTR,in].  Not used.
            ,PtrType,0)
                ;-- lpUsedDefaultChar [LPBOOL, out].  Not used.

    Return &MultiByteStr
    }


;**************************
;*                        *
;*    Helper functions    *
;*                        *
;**************************

;-----------------------------
;
; Function: Edit_GetActiveHandles
;
; Description:
;
;   Finds the handles for the active control and active window.
;
; Parameters:
;
;   hEdit - Variable that contains the handle of the active edit control.
;       [Optional] Value is zero if the active control is not an edit control.
;
;   hWindow - Variable that contains the handle of the active window. [Optional]
;
;   p_MsgBox - Display error message. [Optional] If TRUE, an error MsgBox is
;       displayed if the active control is not an edit control.
;
; Returns:
;
;   Handle of the active edit control or FALSE (0) if the active control is not
;   an edit control.
;
;-------------------------------------------------------------------------------
Edit_GetActiveHandles(ByRef hEdit="",ByRef hWindow="",p_MsgBox=False)
    {
    WinGet hWindow,ID,A
    ControlGetFocus l_Control,A
    if SubStr(l_Control,1,4)="Edit"
        {
        ControlGet hEdit,hWnd,,%l_Control%,A
        Return hEdit
        }

    if p_MsgBox
        MsgBox
            ,262160
                ;-- 262160 = 0 (OK button) + 16 ("Error" icon) + 262144 (AOT)
            ,Error
            ,This request cannot be performed on this control.  %A_Space%

    Return False
    }
