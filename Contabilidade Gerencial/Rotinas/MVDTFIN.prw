#INCLUDE "rwmake.ch"

/*/
	Programa......:	MVDTFIN
	Autor.........:	Everton         
	Data..........:	05/03/2020
	Descricao.....:	GRAVACAO DATA LIMITE PARA OPERACOES FINANCEIRAS
/*/

User Function MVDTFIN

/*
dbSelectArea("SX6")
dbSetOrder(1)
dbSeek(xFilial() + "MV_DATAFIN")
*/
//Private dDataFin := CtoD(Trim(SX6->X6_CONTEUD))

Private dDataFin := GetMv("MV_DATAFIN") // CtoD(Trim(SX6->X6_CONTEUD))

@ 200,250 TO 330,475 DIALOG oDlg2 TITLE "Altera Data"
@ 010,010 TO 045,110 TITLE "Data limite para Operacoes Financeiras:"
@ 025,020 GET dDataFin SIZE 50, 9
@ 050,050 BMPBUTTON TYPE 01 ACTION Grava()
@ 050,080 BMPBUTTON TYPE 02 ACTION Close(oDlg2)
ACTIVATE DIALOG oDlg2

Return()



Static Function Grava()

If !Empty(dDataFin)

	  PUTMV( "MV_DATAFIN", DtoC(dDataFin))
Endif
Close(oDlg2)

Return()
