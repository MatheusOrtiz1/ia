#INCLUDE "PROTHEUS.CH"  

/* -------------------------------------------------------------------------------
Ponto de Entrada para incluir novos campos tela movimentos internos modelo 2
------------------------------------------------------------------------------- */

User Function MT241CAB()  
Local oNewDialog  := PARAMIXB[1]      
Local aCp:=Array(2,2)  

aCp[1][1]="D3_NATUREZ"
aCp[2][1]="D3_CONTA"

    IF PARAMIXB[2]==3   
        aCp[1][2]=SPAC(12)   
        aCp[2][2]=SPAC(20)   

        @ 3.9,00.7 SAY "Natureza" OF oNewDialog   
        @ 3.9,04.0 MSGET aCp[1][2] SIZE 40,08 OF oNewDialog   
        @ 3.9,17.7 SAY "Conta" OF oNewDialog   
        @ 3.9,20.7 MSGET aCp[2][2] SIZE 40,08 OF oNewDialog

    EndIf
return (aCp)  
