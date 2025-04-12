INCLUDE C:\irvine\Irvine32.inc
INCLUDELIB C:\irvine\Irvine32.lib
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
; ==================== Game Title and ASCII Art ====================
titleArt    BYTE "========================================", 10, 13
            BYTE "   _    _  ___  ___ ___   ___  ", 10, 13
            BYTE "  | |  | || _ \| _ \   \ /   \ ", 10, 13
            BYTE "  | |/\| ||   /|   / |) | | | |", 10, 13
            BYTE "  |__/\__||_|_\|_|_\|___/ \___/", 10, 13
            BYTE "                                ", 10, 13
            BYTE "   _    _  _  ___ ___ ___ ___  ___ ", 10, 13
            BYTE "  | |  | |/_\| _ \ _ \_ _/ _ \| _ \\", 10, 13
            BYTE "  | |/\| / _ \   /   /| | (_) |   /", 10, 13
            BYTE "  |__/\__\/ \_\_|_\_|_\___\___/|_|_\\", 10, 13
            BYTE "========================================", 0

; ==================== Menu and Prompts ====================
menu        BYTE "                WORD WARRIOR GAME", 10, 13
            BYTE "     GUESS THE WARLORD SECRET WORD TO DEFEAT HIM!", 10, 13, 10, 13
            BYTE "       CHOOSE CATEGORY OF WORD FROM BELOW:", 10, 13
            BYTE "       1- Weapons of War", 10, 13
            BYTE "       2- War Animals", 10, 13
            BYTE "       3- Battlefield Locations", 10, 13, 10, 13
            BYTE "       0- EXIT GAME ", 0

wordSelectedMsg    BYTE "========================================", 10, 13
                  BYTE "  WARLORD SECRET WORD HAS BEEN CHOSEN! ", 10, 13
                  BYTE "  PREPARE FOR BATTLE, WARRIOR...", 10, 13
                  BYTE "  GUESS THE WORD TO DEFEAT THE WARLORD!", 10, 13
                  BYTE "========================================", 0

enterletterPrompt  BYTE "ENTER LETTER: ", 0

dash        BYTE " _ ", 0

promptCategory     BYTE "ENTER YOUR CHOICE: ", 0

promptDifficulty   BYTE "========================================", 10, 13
                  BYTE "          CHOOSE DIFFICULTY ", 10, 13
                  BYTE "          1) EASY   - 6 LIVES", 10, 13
                  BYTE "          2) MEDIUM - 4 LIVES", 10, 13
                  BYTE "          3) HARD   - 2 LIVES", 10, 13, 10, 13
                  BYTE "ENTER YOUR CHOICE: ", 0

invalidPrompt      BYTE "INVALID! PLEASE ENTER AGAIN...", 0

exitingPrompt      BYTE "========================================", 10, 13
                  BYTE "   RETREATING FROM THE BATTLEFIELD...", 10, 13
                  BYTE "   MAY FORTUNE FAVOR YOU NEXT TIME!", 10, 13
                  BYTE "========================================", 0

correctLetter      BYTE "========================================", 10, 13
                  BYTE "  GREAT, CORRECT LETTER GUESSED!", 10, 13
                  BYTE "  YOU STRIKE THE WARLORD! WARLORD HEALTH DECREASED", 10, 13
                  BYTE "========================================", 0

wrongLetter        BYTE "========================================", 10, 13
                  BYTE "  WRONG GUESS! THE LETTER IS NOT IN THE WORD", 10, 13
                  BYTE "  WARLORD STRIKES! YOUR HEALTH DECREASED", 10, 13
                  BYTE "========================================", 0

winMsg            BYTE "========================================", 10, 13
                  BYTE "       *** GLORIOUS VICTORY! ***", 10, 13
                  BYTE "  CONGRATS! YOU HAVE SUCCESSFULLY GUESSED", 10, 13 
                  BYTE "  THE MYSTERIOUS WORD!", 10, 13
                  BYTE "  THE WARLORD FALLS AND YOUR ARMY TRIUMPHS!", 10, 13
                  BYTE "========================================", 0

loseMsg           BYTE "========================================", 10, 13
                  BYTE "        *** CRUSHING DEFEAT! ***", 10, 13
                  BYTE "  YOU FAILED TO GUESS THE MYSTERIOUS WORD!", 10, 13
                  BYTE "  THE WARLORD REMAINS UNDEFEATED.", 10, 13
                  BYTE "  YOUR ARMY IS CRUSHED IN BATTLE.", 10, 13
                  BYTE "  THE BATTLE IS LOST, BUT THE WAR CONTINUES...", 10, 13
                  BYTE "========================================", 0

statusMsg         BYTE "========================================", 10, 13
                  BYTE "  WARRIOR HEALTH: ", 0
                  
warlordMsg        BYTE "  WARLORD HEALTH: ", 0

wordWasMsg        BYTE "  THE SECRET WORD WAS: ", 0

guessedLettersMsg BYTE "  LETTERS GUESSED: ", 0

; ==================== Game Variables ====================
warrior_health    DWORD 6    ; depends on difficulty level 
warlord_health    DWORD 5    ; depends on size of chosen word
selectedWord      DWORD ?    ; Store address of chosen word
enteredLetters    BYTE 5 DUP(1) ; already guessed positions
guessedLetters    BYTE 26 DUP(0) ; alphabet tracking
letterCount       DWORD 0    ; count of guessed letters

; ==================== Word Categories ====================
; Category 1: Weapons of War (all 5 letters)
weapons     BYTE "SWORD", 0
            BYTE "BOMBS", 0
            BYTE "ARROW", 0
            BYTE "LANCE", 0
            BYTE "SPEAR", 0
weaponsCount DWORD 5  ; Number of words

; Category 2: War Animals (all 5 letters)
animals     BYTE "HORSE", 0
            BYTE "TIGER", 0
            BYTE "EAGLE", 0
            BYTE "SNAKE", 0
            BYTE "WOLVES", 0
animalsCount DWORD 5  ; Number of words

; Category 3: Battlefield Locations (all 5 letters)
locations   BYTE "RIVER", 0
            BYTE "HILLS", 0
            BYTE "FIELD", 0
            BYTE "TOWER", 0
            BYTE "VALLEY", 0
locationsCount DWORD 5  ; Number of words

.code

; ==================== Word Selection Procedure ====================
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
    ret  ; Invalid case (shouldn't happen due to main's validation)

select_weapons:
    mov ecx, weaponsCount  ; ECX = 5
    call Random32          ; EAX = random number
    xor edx, edx
    div ecx                ; EDX = random index (0-4)
    mov eax, edx           ; EAX = index
    mov ebx, 6             ; Each word = 5 letters + 1 null
    mul ebx                ; EAX = index * 6 (offset)
    add eax, OFFSET weapons ; EAX = address of random word
    jmp done

select_animals:
    mov ecx, animalsCount  ; ECX = 5
    call Random32
    xor edx, edx
    div ecx                ; EDX = random index (0-4)
    mov eax, edx
    mov ebx, 6
    mul ebx                ; EAX = index * 6
    add eax, OFFSET animals ; EAX = address of random word
    jmp done

select_locations:
    mov ecx, locationsCount ; ECX = 5
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

; ==================== Display Word Procedure ====================
showWORD PROC
    mov ecx, 5
    mov esi, offset enteredLetters
    
    L2:
        mov al, [esi]
        cmp al, 1
        je notEntered
        call WriteChar
        jmp next
        
    notEntered:
        mov edx, offset dash
        call WriteString
    
    next:
        inc esi
    loop L2
    
    call Crlf
    ret
showWord ENDP

; ==================== Check Letter Procedure ====================
checkLetter PROC, _letter:BYTE
    LOCAL found:BYTE
    
    mov found, 0
    
    ; First record this letter as guessed
    mov al, _letter
    sub al, 'A'            ; Convert to 0-25 index
    movzx ebx, al
    mov guessedLetters[ebx], 1
    
    ; Then check if it's in the word
    mov esi, selectedWord
    mov edi, offset enteredLetters
    mov ecx, 5
    
    L1:
        mov al, [esi]
        cmp al, _letter
        jne wrong
        mov [edi], al
        mov found, 1       ; Flag for the correct guess
        sub warlord_health, 1
        
    wrong:
        inc esi
        inc edi
    loop L1
    
    ; Set return flag
    movzx ebx, found
    
    ret
checkLetter ENDP

; ==================== Check Game State Procedure ====================
checkState PROC
    cmp warlord_health, 0
    je win
    cmp warrior_health, 0
    je lost
    jmp next               ; Else part
    
    win:
        mov ebx, 1
        jmp next

    lost:
        mov ebx, 2
        jmp next
        
    next:
        ret
checkState ENDP

; ==================== Set Difficulty Procedure ====================
setDifficulty PROC, choice_:DWORD
    cmp choice_, 1
    je easy
    cmp choice_, 2
    je med
    cmp choice_, 3
    je hard
    
    easy:
        mov warrior_health, 6
        jmp next
        
    med:
        mov warrior_health, 4
        jmp next
        
    hard:
        mov warrior_health, 2
        jmp next
        
    next:
        ret
setDifficulty ENDP

; ==================== Display Game Status Procedure ====================
displayStatus PROC
    LOCAL i:DWORD
    
    call Clrscr
    
    ; Display warrior and warlord health
    mov edx, OFFSET statusMsg
    call WriteString
    
    mov eax, warrior_health
    call WriteDec
    call Crlf
    
    mov edx, OFFSET warlordMsg
    call WriteString
    
    mov eax, warlord_health
    call WriteDec
    call Crlf
    
    ; Display guessed letters
    mov edx, OFFSET guessedLettersMsg
    call WriteString
    
    mov i, 0
    
show_letters:
    cmp i, 26
    jae show_word
    
    mov ebx, i
    cmp guessedLetters[ebx], 1
    jne skip_letter
    
    ; Display the letter
    mov al, BYTE PTR i
    add al, 'A'
    call WriteChar
    mov al, ' '
    call WriteChar
    
skip_letter:
    inc i
    jmp show_letters
    
show_word:
    call Crlf
    call Crlf
    
    ; Display word with guessed letters
    INVOKE showWORD
    
    call Crlf
    call Crlf
    
    ret
displayStatus ENDP

; ==================== Main Procedure ====================
main PROC
    LOCAL choice:DWORD 

    ; Display title art
    call Clrscr
    mov edx, OFFSET titleArt
    call WriteString
    call Crlf
    call Crlf

    ; Display menu
    mov edx, OFFSET menu
    call WriteString
    call Crlf
    
    ; Get category choice
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

    ; Get difficulty level
diffi:
    call Clrscr
    mov edx, offset promptDifficulty
    call WriteString
    call ReadInt
    
    cmp eax, 3
    ja diffi              ; Invalid choice of difficulty
    INVOKE setDifficulty, eax
    
    ; Initialize warlord health based on word length
    mov warlord_health, 5  ; All words are 5 letters long
    
    ; Display game start message
    call Clrscr
    mov edx, offset wordSelectedMsg
    call WriteString
    call Crlf
    call Crlf

    ; Main game loop
gameloop:
    ; Display game status
    INVOKE displayStatus
    
    ; Get letter guess
    mov edx, offset enterletterPrompt
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    
    ; Convert to uppercase if needed
    cmp al, 'a'
    jb check_letter
    cmp al, 'z'
    ja check_letter
    sub al, 32            ; Convert to uppercase
    
check_letter:
    ; Check if letter is in word
    mov ebx, 0            ; Flag for checkLetter
    INVOKE checkLetter, al
    
    ; Process result
    cmp ebx, 0
    je wrongGuess
    
    mov edx, offset correctLetter
    call WriteString
    jmp check_game_state
    
wrongGuess:
    mov edx, offset wrongLetter
    call WriteString
    sub warrior_health, 1  ; Wrong guess decreases warrior health
    
check_game_state:
    ; Check if game is over
    mov ebx, 0            ; Flag for gameloop checkState
    INVOKE checkState
    
    cmp ebx, 1            ; Win
    je Win
    cmp ebx, 2            ; Lost
    je Loose
    
    ; Wait for a moment before clearing screen
    mov eax, 5000         ; 2 seconds delay
    call Delay
    
    jmp gameloop
    
Win:
    call Clrscr
    mov edx, offset winMsg
    call WriteString
    jmp show_word_result
    
Loose:
    call Clrscr
    mov edx, offset loseMsg
    call WriteString
    
show_word_result:
    call Crlf
    mov edx, offset wordWasMsg
    call WriteString
    mov edx, selectedWord
    call WriteString
    call Crlf
    call Crlf
    
    ; Wait before exiting
    mov eax, 5000         ; 5 seconds delay
    call Delay
    jmp exit_menu
    
invalid_choice:
    mov edx, OFFSET invalidPrompt
    call WriteString
    call Crlf
    
    mov eax, 5000         ; 2 seconds delay
    call Delay
    jmp main
    
exit_menu:
    call Clrscr
    mov edx, OFFSET exitingPrompt
    call WriteString
    call Crlf
    
    invoke ExitProcess, 0
main ENDP
END main