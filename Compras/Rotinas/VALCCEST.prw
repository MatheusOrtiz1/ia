#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³VALCCXEST 	ºDiorgny Natalinoº Data ³  10/04/2017  		   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹
±±ºDesc.     ³ Validação de CENTRO DE CUSTO na Movimentação de Interna    º±±
±±º          ³ incluido ncomo gatilho no campo D3_CC                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
User Function VALCCEST()

	Local lValido 	  := .T.
	Local MVPCOSDCT	  := GETMV("MV_UCOXCC")//Ativa validação tabela Z01 CO X CC 
	local cCCusto     := M->D3_CC 
	Local cCCustoEST  := GETMV("MV_UCCXEST")//Centro de custo de Estoque 
	Local cTipoMov	  := M->D3_TM
  
    IF MVPCOSDCT == .F. /*So entra no teste se o parametro MV_UCCXCO estiver como .T. */
		lValido	:= .T. 
	ELSE
	    IF(EMPTY(cCCusto).OR. (ALLTRIM(cTipoMov)="501" .AND. ALLTRIM(cCCusto)$cCCustoEST))
		   lValido := .F.     
		   msgAlert("Este centro de custo é invalido")
		ENDIF
	ENDIF

Return(lValido)