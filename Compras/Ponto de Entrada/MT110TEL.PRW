#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
���Programa  �MT110TEL  �Autor  �EVERTON FORTI      � Data �  29/07/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �SOLICITA��O DE COMPRA: INCLUS�O DE CAMPO NO CABE�ALHO      ���
�������������������������������������������������������������������������͹��
���Uso       � CONASA                                                     ��
�����������������������������������������������������������������������������
*/
user function MT110TEL()
	Local oNewDialog := PARAMIXB[1]
	Local aPosGet    := PARAMIXB[2]
	//Local nOpcx      := PARAMIXB[3]
	//Local nReg       := PARAMIXB[4]
	Public cGrupoP   := space(04)   

	aadd(aPosGet[1],0) 
	aadd(aPosGet[1],0)
	aPosGet[1,7]:=465
	aPosGet[1,8]:=500
	@ 51,aPosGet[1,7] SAY 'Grupo' PIXEL SIZE 30,9 Of oNewDialog
	@ 50,aPosGet[1,8] MSGET cGrupoP PIXEL SIZE 30,10 F3 "SBM"  PICTURE "@!" Of oNewDialog   


RETURN
