#INCLUDE "RWMAKE.CH"            
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
User Function ITEM()
	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ""
	Local cIdPonto   := ""
	Local cIdModel   := ""
	Local lIsGrid    := .F.
	Local nLinha     := 0
	//Local nQtdLinhas := 0
	Local cMsg       := ""
	//Local nOp
	LOCAL xEmp := SuperGetMV("MV_UFILMX",.F.,"")

	xEmp1 := xEmp

	IF cNumemp $ xEmp1 
		IF !INCLUI
			If (aParam <> NIL)
				oObj := aParam[1]
				cIdPonto := aParam[2]
				cIdModel := aParam[3]
				lIsGrid := (Len(aParam) > 3)

				nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

				If (cIdPonto =="MODELCOMMITNTTS")
					IF nOpc = 3
						cMsg := "Integrar com Maximo esta ."
						cMsg += "Inclusão " + Alltrim(Str(nLinha)) + CRLF

						IF MsgYesNo(cMsg + " Continua?")
							IF SB1->B1_UINTMAX == "S"
								U_MT010INC()
							ENDIF
						ENDIF 

					ELSEIF nOpc = 4
						cMsg :=  "Integrar com Maximo esta ."
						cMsg += "Alteração " + Alltrim(Str(nLinha)) + CRLF

						IF MsgYesNo(cMsg + " Continua?")
							IF SB1->B1_UINTMAX == "S"
								U_MT010INC()
							ENDIF
						ENDIF

					ENDIF
				ENDIF
			EndIf
		ENDIF
	ENDIF
Return (xRet)
