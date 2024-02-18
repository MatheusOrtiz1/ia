/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT120ISC  �Autor  �Everton           � Data �  21/01/15   ���
�������������������������������������������������������������������������͹��
���Desc.     �PONTO DE ENTRADA NO PEDIDO DE COMPRAS                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CONASA                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������t�������������������
*/

USER FUNCTION MT120ISC()

LOCAL AAREA		:= GETAREA()
LOCAL NPOSCO    := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_CO"}) 
//LOCAL NPOSAPROV := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_APROV"})         						// Altera��o feita por Diorgny
LOCAL NCCUSTO   := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_CC"})         						// Altera��o feita por Diorgny
//LOCAL NPOSUPROJ := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_UPROJ"})

ACOLS[N][NPOSCO] := SC1->C1_CO
//ACOLS[N][NPOSUPROJ] := SC1->C1_UPROJ 
    

//ACOLS[N][NPOSAPROV] := POSICIONE("AK5",1,xFILIAL("AK5")+SC1->C1_CO,"AK5_UGRPAP")//INCLUIDO 07/06/2019


IF LEFT(cNumEmp,2)="07"																				// Altera��o feita por Diorgny
//	ACOLS[N][NPOSAPROV] := IF(ALLTRIM(SC1->C1_CC)$"7.02.001.001/7.02.001.002","000002","000001")	// Altera��o feita por Diorgny
	
	IF ExistTrigger(AHEADER[NCCUSTO][2])

  	    RunTrigger(2,NCCUSTO,nil,,'C7_CC')

		SYSREFRESH()
	ENDIF 
   
	IF ExistTrigger(AHEADER[NPOSCO][2])

  	    RunTrigger(2,NPOSCO,nil,,'C7_CO')

		SYSREFRESH()
	ENDIF   
	
ENDIF   

IF ExistTrigger(AHEADER[NCCUSTO][2])

     RunTrigger(2,NCCUSTO,nil,,'SC7->C7_CC')

	SYSREFRESH()
ENDIF 
   
IF ExistTrigger(AHEADER[NPOSCO][2])

    RunTrigger(2,NPOSCO,nil,,'SC7->C7_CO')

	SYSREFRESH()
ENDIF                                                                                               // Altera��o feita por Diorgny

RESTAREA(AAREA)

RETURN(.T.)
