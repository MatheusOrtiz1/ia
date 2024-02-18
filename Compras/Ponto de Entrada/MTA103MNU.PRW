#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTA103MNU
Função principal do ponto de entrada
@author Daniel Gouvea
@since 27/02/2023
@version 1.0
/*/
//-------------------------------------------------------------------
user function MTA103MNU()

	aAdd(aRotina, {"Rejeitar Protocolo"  , "U_REJZAG()", 0, 6, 0, .f.})
	aAdd(aRotina, {"Estorna Classificacao"  , "A140EstCla()", 0 , 5, 0, nil})

	// Ponto de chamada ConexãoNF-e sempre como última instrução.
    U_GTPE010()

return

User Function REJZAG()
	Local _area := getarea()
	Local cEmaRej := alltrim(getmv("MV_UPROREJ"))

	dbselectarea("ZAG")
	dbsetorder(2)//ZAG_FILIAL+ZAG_DOC+ZAG_SERIE+ZAG_FORNEC+ZAG_LOJA
	if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		if ZAG->ZAG_STATUS=="R"
			alert("Protocolo já foi rejeitado.")

		else
            aItem1 := {}
			aCab1 := {	{"F1_FILIAL"    ,SF1->F1_FILIAL          ,NIL},;
				{"F1_DOC"		,SF1->F1_DOC	  ,NIL},;
				{"F1_SERIE"	    ,SF1->F1_SERIE    ,NIL},;
				{"F1_FORNECE"	,SF1->F1_FORNECE  ,NIL},;
				{"F1_LOJA"	    ,SF1->F1_LOJA     ,NIL},;
				{"F1_COND"   	,SF1->F1_COND	  ,NIL},;
				{"F1_EMISSAO"   ,SF1->F1_EMISSAO  ,NIL},;
				{"F1_TIPO"  	,SF1->F1_TIPO     ,NIL} }

			dbselectarea("SD1")
			dbsetorder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			if dbseek(xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
				while !eof() .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA==xFilial()+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
					aadd(aItem1,{	{"D1_FILIAL" , SD1->D1_FILIAL   			  ,NIL},;
						{"D1_ITEM"	 , SD1->D1_ITEM			  ,NIL},;
						{"D1_COD"	 , SD1->D1_COD			  ,NIL},;
						{"D1_QUANT"  , SD1->D1_QUANT		  ,NIL},;
						{"D1_VUNIT"	 , SD1->D1_VUNIT 		  ,NIL},;
						{"D1_TOTAL"	 , SD1->D1_TOTAL	      ,NIL},;
						{"D1_LOCAL"  , SD1->D1_LOCAL    	  ,NIL}})
					dbselectarea("SD1")
					dbskip()
				enddo
			endif
            LMSERROAUTO := .f.
			if len(aCab1)>0 .and. len(aItem1)
				MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab1,aItem1,5)  //PRE-NOTA
				if LMsErroAuto
					alert("Não foi possível excluir a pre-nota")
					mostraerro()
				else
					msginfo("Excluido com sucesso.","")
					lRet := .T.
                    cMsg := "Protocolo de Recebimento Rejeitado. "+ZAG->ZAG_DOC+"/"+ZAG->ZAG_SERIE+CHR(13)+CHR(10)
					cMsg += "Motivo da Rejeição: "+chr(13)+chr(10)

					DEFINE MSDIALOG oDlg TITLE "Motivo Rejeição" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
					@ 020,010 Get cMsg Size 230,100 MEMO of oDlg Pixel
					@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
					ACTIVATE MSDIALOG oDlg CENTERED
					oEmail := pfwEMail():New()
					cPara := alltrim(usrretmail(__cUserID))+";"+alltrim(usrretmail(ZAG->ZAG_CODUSR))
					if !empty(cEmaRej)
						cPara += ";"+cEmaRej
					endif 

					dbselectarea("ZAG")
					if reclock("ZAG",.F.)
						ZAG->ZAG_STATUS := "R"
						ZAG->ZAG_LOGERR := ZAG->ZAG_LOGERR + " | REJEITADO : "+ cMsg
						msunlock()
					endif

					oEmail:SetTo(cPara)
					oEmail:SetSubject("Protocolo Rejeitado, empresa: " + cEmpAnt+" filial "+cFilAnt)
					oEmail:SetBody(cMsg)
					oEmail:Send()

					oEmail:Destroy()

				endif
			endif
		endif
	else
		alert("Não existe protocolo pra esse documento de entrada.")
	endif

	restarea(_area)
return
