; עמית כספי

IDEAL
MODEL small
STACK 100h
DATASEG

    mesEnterValueForN db 'please enter the length of the squares side(2-6):',10,13,'$'
	mesNRangeNotOk db 'the length of the squares side is not ok(not in range)',10,13,'$'
	mesInputNumbers db 'enter number (2 digits) for the square',10,13,'$'
	mesNumTooSmall db 'there is number that smaller than one',10,13,'$'
	mesNumTooHigh db 'there is number that higher than n baribua',10,13,'$'
	mesNumTooMany db 'there is number that appears more than once in the square',10,13,'$'
	mesSumRowNotOk db 'The sum of the row is not ok',10,13,'$'
	mesSumColumnNotOk db 'The sum of the column is not ok',10,13,'$'
	mesSumLeftDiagonalNotOk db 'The sum of the left diagonal is not ok',10,13,'$'
	mesSumRightDiagonalNotOk db 'The sum of the right diagonal is not ok',10,13,'$'
	mesItsMagicSquare db 'its a magic square!',10,13,'$'
	counter db 0 ; משתנה מונה בפעולות השורות והטורים שבעזרתו ניתן לעבור בדיוק על כל המספרים בשורה/טור, ולא יותר או פחות  
	             ; (נעשה באמצעות השוואת המשתנה לאורך צלע הריבוע)
	counter1 db 0 ; משתנה מונה בפעולת בדיקת כפילות המספרים
	              ; מאפשר לבדוק האם יש כפילות של אחד המספרים במערך, אם המשתנה גדול מ1 סימן שישנה כפילות. 
	address dw ? 
	address1 dw ? 
	n db ? ;אורך צלע הריבוע
	sum db 0 ; "הסכום הקסום"
	a db ? ;

CODESEG
 
proc InputN
; פעולה שקולטת ערך לאורך צלע הריבוע, אם הקלט אינו תקין ממשיך לקלוט עד לתקינות הקלט
    pop [address]
nNotInRange:
    push offset mesEnterValueForN
	call PrintMes
	xor ax, ax
	mov ah, 1
	int 21h ;al contain the digit
	cmp al, '1'
	jbe nNotOk
	cmp al, '6'
	jbe endInputN
nNotOk:
    call DownLine
	push offset mesNRangeNotOk
	call PrintMes
	jmp nNotInRange
endInputN:
	push ax
	call DownLine
	push [address]
	ret
endp InputN

proc DownLine
    mov dl, 10
	mov ah, 2
	int 21h
	mov dl, 13
	int 21h
	ret
endp DownLine

proc InputTheArray 
; פעולה שקולטת ערכים לתוך המערך, ריבוע הקסם
; צריך להכניס מספר בעל 2 ספרות. אם המספר הוא חד ספרתי, יש להוסיף לפניו את הספרה 0
; הפעולה מקבלת את offset a 
    pop [address]
	pop bx
	mov cl, al ;nxn, for the loop
inputNumbers:
    push offset mesInputNumbers
	call PrintMes
	xor ax, ax
	xor dx, dx
	mov ah, 1
	int 21h 
	sub al, 30h
	mov dl, 10
	mul dl ; הכפלה ב10= ספרת העשרות
	mov dx, ax
	mov ah, 1
	int 21h
	sub al, 30h
	add dl, al
	mov [byte ptr bx], dl ;השמת ערך המספר שנקלט במערך
	inc bx
	call DownLine
	loop inputNumbers
	push [address]
	ret
endp InputTheArray
	
proc CheckNumsRange
; פעולה שבודקת האם המספרים שנקלטו למערך בטווח תקין או לא (אחד עד אורך צלע הריבוע->בריבוע, כולל)
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת את offset a, ומחזירה את ערך si. 
    pop [address]
	pop bx 
	mov cl, al ;nxn, for the loop
	mov dl, al ;nxn
	mov si, 1
checkNumsArray:
    xor ax, ax 
	cmp [bx], al
	jbe numNotOkTooSmall
	cmp [bx], dl
    ja numNotOkTooHigh 
	inc bx 
    loop checkNumsArray 
	jmp endNumsRange
numNotOkTooSmall:
    push offset mesNumTooSmall
	jmp endNumNotInRange
numNotOkTooHigh:
    push offset mesNumTooHigh
endNumNotInRange:
	mov si, 0
	call PrintMes
endNumsRange:
    mov al, dl;nxn
    mov cl, dl;nxn
	push si
	push [address]
	ret
endp CheckNumsRange
	
proc CheckSameNums
; פעולה שבודקת האם ישנה כפילות של מספרים במערך. 
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת כל פעם כתובת במערך לאוגר ביאיקס, ומשווה אותו עם אוגר דיאיי
; אוגר דיאיי מכיל בכל פעם בתחילת הפעולה את אופסט המערך וגדל בתוך הפעולה עצמה באחד
; אוגר ביאיקס גדל ב1 מחוץ לפעולה זו, בלולאה שבפעולה הראשית שבה ישנו הזימון לפעולה
; כך כל בכל פעם בפעולה ישנה השוואה בין כתובת מסוימת לכל הכתובות האחרות במערך, כולל אותה הכתובת הספיציפית
; אם שני האוגרים הללו שווים המשתנה המונה גדל ב1, אם הוא גדול מ1, סימן שישנה כפילות!
    mov [counter1], 0
    pop [address]
	pop bx ;כתובת של המערך
	pop di ;offset a
	mov cl, al ;nxn, for the loop
checkNumInArray:
	mov dl, [byte ptr bx]
    cmp dl, [byte ptr di]
	jne notSame
	inc [counter1]
	cmp [counter1], 1
	ja moreThanOneNum
notSame:
    inc di
	loop checkNumInArray
	mov si, 1 
	jmp endCheckSameNums
moreThanOneNum:
    mov si, 0
    push offset mesNumTooMany
	call PrintMes
endCheckSameNums:
    push si
	push [address]
    ret	
endp CheckSameNums

proc PrintMes
    pop [address1]
	pop dx ;אופסט ההודעה המתאימה
	mov ah, 9h 
	int 21h
	push [address1]
	ret
endp PrintMes

proc SumRows
; את הפעולה לחישוב סכום המספרים בשורה(n פעמים) פעולה שמזמנת
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת את offset a, ומחזירה את ערך si. 
    pop [address]
	pop bx ;offset a 
	mov cl, [n] 
checkRows:
    push bx
    xor dx, dx ;האוגר שיכיל את הסכום בכל שורה
	mov [counter], 0 ;נשווה את ערך המשתנה לערך אורך צלע הריבוע ובכך נחשב את סכום המספרים בשורה בדיוק
	call SumOneRow
	pop si
	cmp si, 0
	je sumRowNotOk
	loop checkRows
	jmp endSumRows
sumRowNotOk:
    push offset mesSumRowNotOk
	call PrintMes
endSumRows:
    push si
	push [address]
	ret
endp SumRows

proc SumOneRow
; פעולה שמחשבת את סכום המספרים בשורה ובודקת האם הוא שווה לסכום הקסום
; si הפעולה מקבלת כתובת במערך (הכתובת גדלה במהלך פעולה זו), ומחזירה את ערך האוגר. 
    pop [address1]
	pop bx
	mov si, 1  
checkOneRow:
    add dl, [bx]
	inc bx
	inc [counter]
	mov al, [counter]
	cmp al, [n]
	jne checkOneRow
	; בנקודה זו ניתן להסיק שסכום כל המספרים בשורה חושב
	cmp dl, [sum]
	je endProcSumOneRow
	mov si, 0
endProcSumOneRow:	
	push si 
	push [address1]
	ret
endp SumOneRow

proc SumColumns
; פעולה לחישוב סכום המספרים בטור (n פעמים) פעולה שמזמנת 
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת את offset a, ומחזירה את ערך si. 
    pop [address]
	pop di ;offset a
    xor cx, cx	
	mov cl, [n] 
checkColumns:
    push di ;כתובת של התחלת טור כלשהו במערך
    xor dx, dx ;האוגר שיכיל את הסכום בכל שורה
	xor ax, ax
	mov [counter], 0 ;נשווה את ערך המשתנה לערך אורך צלע הריבוע ובכך נחשב את סכום המספרים בטור בדיוק
	call SumOneColumn
	pop si
	cmp si, 1
	jne sumColumnNotOk
	inc di 
	loop checkColumns
	jmp endSumColumns
sumColumnNotOk:
    push offset mesSumColumnNotOk
	call PrintMes
endSumColumns:
	push si
	push [address]
	ret
endp SumColumns

proc SumOneColumn
; פעולה שמחשבת את סכום המספרים בטור ובודקת האם הוא שווה לסכום הקסום
; si הפעולה מקבלת כתובת של תחילת טור במערך (הכתובת גדלה במהלך פעולה זו), ומחזירה את ערך האוגר  
    pop [address1]
	pop bx
	mov si, 1  
checkOneColumn:
    add dl, [bx]
	add bl, [n] 
	inc [counter]
	mov al, [counter]
	cmp al, [n]
	jne checkOneColumn
	; בנקודה זו ניתן להסיק שסכום כל המספרים בטור חושב
	cmp dl, [sum]
	je endSumOneColumn
	mov si, 0
endSumOneColumn:	
	push si 
	push [address1]
	ret
endp SumOneColumn

proc SumLeftDiagonal
; פעולה שמחשבת את סכום המספרים באלכסון השמאלי ובודקת האם הוא שווה לסכום הקסום
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת את offset a, ומחזירה את ערך si. 
    pop [address]
	pop bx ;offset a  
	mov cl, [n] 
	xor dx, dx ;האוגר שיכיל את סכום המספרים באלכסון 
checkLeftDiagonal:
    add dl, [bx]
	add bl, [n]
	inc bx 
	loop checkLeftDiagonal
	mov si, 1
	cmp dl, [sum]
	je endSumLeftDiagonal
	mov si, 0 
    push offset mesSumLeftDiagonalNotOk
	call PrintMes
endSumLeftDiagonal:
	push si
	push [address]
	ret
endp SumLeftDiagonal

proc SumRightDiagonal
; פעולה שמחשבת את סכום המספרים באלכסון הימני ובודקת האם הוא שווה לסכום הקסום
; אם תקין si=1, ואם לא תקין si=0 (ואז יוצא עם הודעת שגיאה).
; הפעולה מקבלת את offset a, ומחזירה את ערך si. 
    pop [address]
	pop bx ;offset a
	mov cl, [n] 
	xor dx, dx ;האוגר שיכיל את סכום המספרים באלכסון 
	add bl, [n]  
	dec bx ;כדי להגיע לכתובת תחילת האלכסון הימני
checkRightDiagonal:
    add dl, [bx]
	add bl, [n] 
	dec bx 
	loop checkRightDiagonal
	mov si, 1
	cmp dl, [sum]
	je endSumRightDiagonal
	mov si,0 
	push offset mesSumRightDiagonalNotOk
	call PrintMes
endSumRightDiagonal:
    push si
	push [address]
	ret
endp SumRightDiagonal

start:
	mov ax, @data
	mov ds, ax
	call InputN
	pop ax
	sub al, 30h
	mov [n], al
	mov ah, 0
	xor cx, cx
	mul al ;ax=nxn
	push ax ;כדי "לשמור" את הערך של האוגר (שמכיל את אורך הצלע של הריבוע בריבוע) בשביל הפעולות הבאות 
	push offset a
	call InputTheArray
	pop ax ;כדי לשמור את הערך של אייאל 9 לפעולות הבאות אחרי שהערך נהרס
	xor dx, dx
	push offset a
	call CheckNumsRange
	pop si 
	cmp si, 0
	je toExit
	mov bx, offset a
sendAddress:
    push cx ;כדי "לשמור" את הערך של האוגר (שמכיל את אורך הצלע של הריבוע בריבוע) בשביל לולאת הלופ
	push offset a
	push bx
	call CheckSameNums
	pop si
	cmp si, 0
	je exit
	inc bx
	pop cx
	loop sendAddress
	inc al
	mul [n]
	shr ax, 1
	mov [sum], al 
	push offset a 
	call SumRows
	pop si 
	cmp si, 0
	je exit
	jmp continueProg
toExit: ;exit תווית קפיצה ל
    jmp exit
continueProg:
    push offset a  
	call SumColumns
	pop si 
	cmp si, 0
	je exit
	push offset a
	call SumLeftDiagonal
	pop si
	cmp si, 0
	je exit
	push offset a
	call SumRightDiagonal
	pop si	
	cmp si, 0
	je exit
	; בנקודה זו ניתן להסיק שהריבוע הינו ריבוע קסם תקין! 
	push offset mesItsMagicSquare
	call PrintMes
exit:
	mov ax, 4c00h
	int 21h
END start

