INCLUDE C:\irvine\Irvine32.inc
INCLUDELIB C:\irvine\Irvine32.lib
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data

; original menu 
menu BYTE "WORD WARRIOR GAME", 10, 13
     BYTE "GUESS THE WARLORD SECRET WORD TO DEFEAT HIM!", 10, 13, 10, 13
     BYTE "CHOOSE CATEGORY OF WORD FROM BELOW:", 10, 13
     BYTE "1- Weapons of War", 10, 13
     BYTE "2- War Animals", 10, 13
     BYTE "3- Battlefield Locations", 10,13,10,13
     BYTE "0- EXIT GAME ",0

wordSelectedMsg byte "WARLORD SECRET WORD HAS BEEN CHOOSEN! ", 10,13
                byte "GUESS THE WORD TO DEFEAT THE WARLORD...",10,13,0

enterletterPrompt byte "ENTER LETTER: ",0

dash BYTE " _ ",0

promptCategory BYTE "ENTER YOUR CHOICE: ",0
promptDifficulty BYTE "CHOOSE DIFFICULTY ",10,13
                   byte "1)EASY ",10,13
                   byte "2)MEDIUM ",10,13
                   byte "3)HARD",10,13,10,13
                   byte  "ENTER YOUR CHOICE: ",0
invalidPrompt BYTE "INVALID! PLEASE ENTER AGAIN...",0

exitingPrompt BYTE "EXITING THE PROGRAME... BYE!",0

correctLetter Byte "GREAT, CORRECT LETTER GUESSED!",10,13
              byte "YOU STRIKE THE WARLORD! WARLORD HEALTH DECREASED",10,13,0

wrongLetter byte "WRONG GUESS! ",10,13
            byte "WARLORD STRIKES! YOUR HEALTH DECREASED",10,13,0

winMsg byte "CONGRATS! YOU HAVE SUCCESSFULLY GUESSED THE MYSTERIOUS WORD!",10,13
        byte "YOU HAVE WON THE GAME! WARLORD DEFEATED", 10,13,0

loseMsg byte "DEFEAT! YOU FAILED TO GUESS THE MYSTERIOUS WORD!",10,13
        byte "THE WARLORD REMAINS UNDEFEATED. YOUR ARMY IS CRUSHED.",10,13
        byte "THE BATTLE IS LOST, BUT THE WAR CONTINUES...",10,13,0

warrior_health DWORD 6  ; depends on difiiculty level 
warlord_health DWORD 5  ; depends on size of chosen word
selectedWord DWORD ?  ; Store address of chosen word
enteredLetters byte 5 dup(1) ; already guessed
tempMsg BYTE "Selected word: ", 0

; Category 1: Weapons of War (all 5 letters)
weapons BYTE "SWORD", 0
        BYTE "BOMBS", 0
        BYTE "ARROW", 0
        BYTE "LANCE", 0
        BYTE "SPEAR", 0
weaponsCount DWORD 5  ; Number of words

; Category 2: War Animals (all 5 letters)
animals BYTE "HORSE", 0
        BYTE "TIGER", 0
        BYTE "EAGLE", 0
        BYTE "SNAKE", 0
        BYTE "WOLVES", 0
animalsCount DWORD 5  ; Number of words

; Category 3: Battlefield Locations (all 5 letters)
locations BYTE "RIVER", 0
          BYTE "HILLS", 0
          BYTE "FIELD", 0
          BYTE "TOWER", 0
          BYTE "VALLEY", 0
locationsCount DWORD 5  ; Number of words





;           .code


.code



wordSelect PROC, _choice:DWORD
    ; Initialize random seed (only needed once, could move to main)
    call Randomize

    ; Check choice and jump to appropriate category
    cmp _choice, 1
    je select_weapons
    cmp _choice, 2
    je select_animals
    cmp _choice, 3
    je select_locations
    ret  ; Invalid case (shouldn’t happen due to main’s validation)

select_weapons:
    mov ecx, weaponsCount  ; EAX = 5
    call Random32          ; EAX = random number
    xor edx, edx
    div ecx                ; EDX = random index (0-4)
    mov eax, edx           ; EAX = index
    mov ebx, 6             ; Each word = 5 letters + 1 null
    mul ebx                ; EAX = index * 6 (offset)
    add eax, OFFSET weapons ; EAX = address of random word
    jmp done

select_animals:
    mov ecx, animalsCount  ; EAX = 5
    call Random32
    xor edx, edx
    div ecx                ; EDX = random index (0-4)
    mov eax, edx
    mov ebx, 6
    mul ebx                ; EAX = index * 6
    add eax, OFFSET animals ; EAX = address of random word
    jmp done

select_locations:
    mov ecx, locationsCount ; EAX = 5
    call Random32
    xor edx, edx
    div ecx                ; EDX = random index (0-4)
    mov eax, edx
    mov ebx, 6
    mul ebx                ; EAX = index * 6
    add eax, OFFSET locations ; EAX = address of random word

done:
    ; EAX holds the address of the selected word
    ret
wordSelect ENDP

showWORD proc
    mov ecx, 5
    mov esi , offset enteredLetters
    l2:
        mov al , [esi]
        cmp al, 1
        je notEntered
        call WriteChar
        jmp next
        notEntered:
        mov edx, offset dash
        call WriteString
        next:
            inc esi
    loop l2
    ret
showWord endp

checkLetter proc, _letter:byte
    mov esi , selectedWord
    mov edi , offset enteredLetters
    mov ecx, 5
    L1:
        mov al , [esi]
        cmp al, _letter
        jne wrong
        mov [edi],al
        mov ebx,1           ; flag for the correct guess
        sub warlord_health, 1
        wrong:
           inc esi
           inc edi

    loop L1

    ret
checkLetter endp

checkState proc
    cmp warlord_health , 0
    je win
    cmp warrior_health, 0
    je lost
    jmp next ; else part
    win:
        mov ebx, 1
        jmp next

    lost:
        mov ebx, 2
        jmp next
    next:

    ret
checkState endp


setDifficulty proc, choice_:DWORD
    cmp choice_,1
    je easy
    cmp choice_,2
    je med
    cmp choice_,3
    je hard
    easy:
         mov warrior_health,6
         jmp next
    med:
         mov warrior_health,4
         jmp next
    hard:
          mov warrior_health,2
         jmp next
    next:
    ret
setDifficulty endp


main PROC
    LOCAL choice:DWORD 

    mov edx, OFFSET menu
    call WriteString
    call Crlf
    mov edx, OFFSET promptCategory
    call WriteString
    call ReadInt
    cmp eax, 0
    je exit_menu
    cmp eax, 3
    ja invalid_choice
    mov choice, eax
    invoke wordSelect, choice
    mov selectedWord, eax  ; Save word address

    diffi:
    mov edx, offset promptDifficulty
    call WriteString
    call ReadInt
    cmp eax, 3
    ja diffi ; invalid choice of difficulty
    INVOKE setDifficulty, eax
    


    ; Test: Display the word
    mov edx, OFFSET tempMsg
    call WriteString
    mov edx, selectedWord
    call WriteString
    call Crlf
    mov edx , offset wordSelectedMsg
    call WriteString
    gameloop:
    mov edx, offset enterletterPrompt
    call WriteString
    call ReadChar
    call WriteChar
    mov ebx,0           ;flag for checkLetter
    Invoke checkLetter, al       ;;;;
    cmp ebx,0
    je wrongGuess
    mov edx, offset correctLetter
    call WriteString
    jmp next
    wrongGuess:
    mov edx , offset wrongLetter
    call WriteString
    sub warrior_health, 1 ; wrong guess decreses warrior health
    next:
    INVOKE showWord
    mov ebx , 0     ; flag for gameloop checkState
    INVOKE checkState
    cmp ebx,1 ; win 
    je Win
    cmp ebx, 2; lost
    je Loose
    jmp gameloop
    Win:
        mov edx , offset winMsg
        call WriteString
        jmp exit_menu
    Loose:
        mov edx, offset loseMsg
        call WriteString
         jmp exit_menu
invalid_choice:
    mov edx, OFFSET invalidPrompt
    call WriteString
    call Crlf
    jmp main
exit_menu:
    mov edx, OFFSET exitingPrompt
    call WriteString
    call Crlf
    invoke ExitProcess, 0
main ENDP
END main