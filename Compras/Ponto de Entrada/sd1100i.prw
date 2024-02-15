#INCLUDE "PROTHEUS.CH"

/*±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³PROGRAMA  ³TAMCOM03 ³ AUTOR ³ EVERTON                ³ DATA ³28/08/2017 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³DESCRI‡…O ³ATUALIZA A CONTA ORÇAMENTARIA NO CADASTRO DO PRODUTO		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´*/

user function sd1100i()

Local aArea:=GetArea()

// ATUALIZA A CONTA ORÇAMENTARIA NO CADASTRO DO PRODUTO
	SB1->(DbSetOrder(1))
    	if SB1->( DbSeek( xFilial("SB1")+SD1->D1_COD) ) 
              SB1->( RecLock("SB1",.F.) )
               SB1->B1_UCO := SD1->D1_CO
               SB1->( MsUnlock("SB1") )
         Endif

RestArea(aArea)

Return()