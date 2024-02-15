//-----------------------------------------------------//
//Ponto de entrada para preencher a data de liberação  //
//-----------------------------------------------------//
USER FUNCTION MT094LOK()
        
local aArea := GetArea()
local aAreaSC7 := SC7->(GetArea())
local aAreaSCR := SCR->(GetArea())

DBSELECTAREA("SC7")
DBSETORDER(1)
IF DBSEEK(xFilial("SC7")+Alltrim(SCR->CR_NUM))
	While SC7->(!Eof()) .AND. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == SC7->C7_FILIAL+Alltrim(SC7->C7_NUM)
		///PREENCHER TODOS OS CAMPOS SO PEDIDO
		IF RECLOCK("SC7",.F.)
			SC7->C7_DATALIB := DDATABASE
			MSUNLOCK()
		ENDIF
	SC7->(DBSKIP())
	ENDDO
ENDIF 

RestArea(aArea)
RestArea(aAreaSC7)
RestArea(aAreaSCR)
RETURN()
