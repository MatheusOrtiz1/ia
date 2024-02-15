#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
/*
�����������������������������������������������������������������������������
���Programa  �VALCCXEST 	�Diorgny Natalino� Data �  10/04/2017  		   ��
���������������������������������������������������������������������������͹
���Desc.     � Valida��o de CENTRO DE CUSTO na Movimenta��o de Interna    ���
���          � incluido ncomo gatilho no campo D3_CC                      ���
�������������������������������������������������������������������������͹��
*/
User Function VALCCEST()

	Local lValido 	  := .T.
	Local MVPCOSDCT	  := GETMV("MV_UCOXCC")//Ativa valida��o tabela Z01 CO X CC 
	local cCCusto     := M->D3_CC 
	Local cCCustoEST  := GETMV("MV_UCCXEST")//Centro de custo de Estoque 
	Local cTipoMov	  := M->D3_TM
  
    IF MVPCOSDCT == .F. /*So entra no teste se o parametro MV_UCCXCO estiver como .T. */
		lValido	:= .T. 
	ELSE
	    IF(EMPTY(cCCusto).OR. (ALLTRIM(cTipoMov)="501" .AND. ALLTRIM(cCCusto)$cCCustoEST))
		   lValido := .F.     
		   msgAlert("Este centro de custo � invalido")
		ENDIF
	ENDIF

Return(lValido)