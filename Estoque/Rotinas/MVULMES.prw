#INCLUDE "rwmake.ch"

/*/
	Programa......:	MVULMES
	Autor.........:	EVERTON FORTI         
	Data..........:	12/07/2016
	Descricao.....:	GRAVACAO DATA LIMITE PARA OPERACOES ESTOQUE
/*/

User Function MVULMES

Private dDataEst := GetMv("MV_ULMES") // CtoD(Trim(SX6->X6_CONTEUD))

@ 200,250 TO 330,475 DIALOG oDlg2 TITLE "Altera Data"
@ 010,010 TO 045,110 TITLE "Data do Fechamento do Estoque:"
@ 025,020 GET dDataEst SIZE 50, 9
@ 050,050 BMPBUTTON TYPE 01 ACTION Grava()
@ 050,080 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2

Return()



Static Function Grava()

If !Empty(dDataEst)
	dbSelectArea("SX6")
	dbSetOrder(1)
	If dbSeek(cFilant + "MV_ULMES")
   	   RecLock("SX6",.F.)
       SX6->X6_CONTEUD := DtoC(dDataEst)
   	   MsUnlock()
	Else
	   If dbSeek("  " + "MV_ULMES")
    	  RecLock("SX6",.F.)
	      SX6->X6_CONTEUD := DtoC(dDataEst)
    	  MsUnlock()
       EndIf	  
	EndIf
Endif
Close(oDlg2)

Return()
