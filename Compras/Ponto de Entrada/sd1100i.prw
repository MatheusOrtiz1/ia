#INCLUDE "PROTHEUS.CH"

/*�����������������������������������������������������������������������Ŀ��
���PROGRAMA  �TAMCOM03 � AUTOR � EVERTON                � DATA �28/08/2017 ��
�������������������������������������������������������������������������Ĵ��
���DESCRI��O �ATUALIZA A CONTA OR�AMENTARIA NO CADASTRO DO PRODUTO		  ���
�������������������������������������������������������������������������Ĵ*/

user function sd1100i()

Local aArea:=GetArea()

// ATUALIZA A CONTA OR�AMENTARIA NO CADASTRO DO PRODUTO
	SB1->(DbSetOrder(1))
    	if SB1->( DbSeek( xFilial("SB1")+SD1->D1_COD) ) 
              SB1->( RecLock("SB1",.F.) )
               SB1->B1_UCO := SD1->D1_CO
               SB1->( MsUnlock("SB1") )
         Endif

RestArea(aArea)

Return()