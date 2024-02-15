#INCLUDE "rwmake.ch"

/*/
	Programa......:	MVUFINCOM
	Autor.........:	EVERTON FORTI         
	Data..........:	12/07/2016
	Descricao.....:	GRAVACAO DATA LIMITE PARA OPERACOES FINANCEIRAS
/*/

User Function MVUFIMCOM

Private dDataFin := GetMv("MV_UFINCOM")

@ 200,250 TO 330,475 DIALOG oDlg2 TITLE "Altera Data"
@ 010,010 TO 045,110 TITLE "Data limite para Operacoes do Compras:"
@ 025,020 GET dDataFin SIZE 50, 9
@ 050,050 BMPBUTTON TYPE 01 ACTION Grava()
@ 050,080 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2

Return()                                                              



Static Function Grava()

If !Empty(dDataFin)
	dbSelectArea("SX6")
	dbSetOrder(1)
	If dbSeek(cFilant + "MV_UFIMCOM")
   	   RecLock("SX6",.F.)
       SX6->X6_CONTEUD := DtoS(dDataFin)
   	   MsUnlock()
	Else
	   If dbSeek("  " + "MV_UFIMCOM")
    	  RecLock("SX6",.F.)
	      SX6->X6_CONTEUD := DtoS(dDataFin)
    	  MsUnlock()
       EndIf	  
	EndIf
Endif
Close(oDlg2)

Return()
