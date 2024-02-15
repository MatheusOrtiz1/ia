#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//Static __oModelAut := NIL //variavel oModel para substituir msexecauto em MVC

/// ROTINA AUTOMATICA - EXCLUSÃO DE CONTA CONTABIL CTB
User Function A020DELE()
//Local nOpcAuto :=0
//Local nX
//Local aLog
//Local cLog :=""
Local lRet := .T.
Local cContaCT1:=M->A2_CONTA

DBSELECTAREA("CVD")
If DbSeek( xFilial("CVD") + PadR(cContaCT1,Len(CVD->CVD_CONTA)))
	IF RECLOCK("CVD",.F.)
		DBDELETE()
		CVD->(MSUNLOCK())
	endif
Endif
DBSELECTAREA("CT1")
	If DbSeek( xFilial("CT1") + PadR(cContaCT1,Len(CT1->CT1_CONTA)))
		IF RECLOCK("CT1",.F.)
			DBDELETE()
			CT1->(MSUNLOCK())
		endif
	endif
	

Return( lRet )
