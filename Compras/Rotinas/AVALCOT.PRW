#INCLUDE "RWMAKE.CH"            
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

Static lC7_CO		:= SC7->(FieldPos("C7_CO")) > 0
Static lC7_DESCCC	:= SC7->(FieldPos("C7_DESCCC")) > 0
Static lC7_DESCCO	:= SC7->(FieldPos("C7_DESCCO")) > 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ                                                          
±±³PROGRAMA  ³ATENDIMENTO ³ AUTOR ³ EVERTON FORTI    ³ DATA ³ 30/01/2019  ³±±
³±±-----------------------------------------------------------------------³±±
±±³Ponto de entrada para gravar Conta orçamentaria no pedido de Compras   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
user function AVALCOT()
	Local nEvento := PARAMIXB[1] //Valor 4
	Local aArea := GetArea()
	Local cCO := ""

	If nEvento == 4

		nFilial     := SC7->C7_FILIAL
		nProduto    := SC7->C7_PRODUTO
		nFornece    := SC7->C7_FORNECE
		nItem       := SC7->C7_ITEMSC
		nLoja       := SC7->C7_LOJA
		nNum        := SC7->C7_NUMSC
		nQuant      := SC7->C7_QUANT
		dEmi        := SC7->C7_EMISSAO

		cPedItem       := SC7->C7_ITEM
		cPedNum        := SC7->C7_NUM
        cCcusto        := SC7->C7_CC
		//----------------------------------------------------
		dbSelectArea("SC1")
		dbSetOrder(1) //C1_FILIAL+ C1_NUM+ C1_ITEM
		IF dbSeek(xFILIAL("SC1")+nNum+nItem )

			WHILE !EOF() .AND. SC1->C1_FILIAL+SC1->C1_PRODUTO+ SC1->C1_NUM+ SC1->C1_ITEM+ SC1->C1_FORNECE+ SC1->C1_LOJA == nFilial + nProduto + nNum + nItem +  nFornece + nLoja
				IF SC1->C1_QUANT == nQuant 
					cCO := SC1->C1_CO
						//Gravar o CCO da SC1 em SC7
					dbSelectArea("SC7")
					//dbSetOrder(1) //C7_FILIAL+C7_PRODUTO+C7_FORNECE+C7_LOJA
					IF dbSeek(nFilial+cPedNum+cPedItem)
                        RecLock("SC7",.F.)
                            If lC7_CO
								SC7->C7_CO     := cCO
							EndIf
                            If lC7_DESCCC
								SC7->C7_DESCCC := POSICIONE("CTT",1,xFilial("CTT")+cCcusto,"CTT_DESC01")
							EndIf
                            If lC7_DESCCO
								SC7->C7_DESCCO := POSICIONE("AK5",1,xFILIAL("AK5")+cCO,"AK5_DESCRI")                            
							EndIf
                        MsUnlock()
					EXIT
                    ENDIF
				ENDIF

				dbSelectArea("SC1")
				dbSkip()

			ENDDO
		ENDIF
	EndIf

	RestArea(aArea)
return
