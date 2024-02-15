#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RETNUMCAD �Autor  �Paulo Pego          � Data �  10/09/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o proximo numero de Cliente/Forncedores            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Parametro � cTIPO =  SA1 - Cadastro Clientes                           ���
���          �          EX1 - Cadastro Clientes Exportacao                ���
���          �          SA2 - Cadastro de Fonecedores                     ���
���          �          EX2 - Cadastro Fornecedores Expotacao             ���
�������������������������������������������������������������������������͹��
���Retorno   � cRET - Codigo do proximo Numero a ser utilizado            ���
�������������������������������������������������������������������������͹��
���Uso       � Utilizado Soluvel/Embalagem/Alimentos/RH                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function RETNUMCAD(cTIPO)
Local aAREA := GetArea(), aSA1 := SA1->(GetArea()), aSA2 := SA2->(GetArea())

If !inclui
   If cTIPO $ "SA1/EX1"
      Return SA1->A1_COD
   Else
      Return SA2->A2_COD
   Endif
Endif

Do While .T.
   cRET := MyProxNum(cTIPO)

   If cTIPO $ "SA1/EX1"
      SA1->( DbSetOrder(1) )
      If !SA1->( DbSeek( xFilial("SA1") + cRET ))  
         Exit 
      Endif
   Else   
      SA2->( DbSetOrder(1) )
      If !SA2->( DbSeek( xFilial("SA2") + cRET ))  
         Exit 
      Endif
   Endif               

EndDo

 
SA1->(RestArea(aSA1))
SA2->(RestArea(aSA2))

RestArea(aAREA)
Return cRET

//---------------------------------------------------------------------------------------------------------------//
Static Function MyProxNum(cTIPO)

DbSelectArea("Z00")
If !DbSeek(xFilial("Z00")+cTIPO)
   RecLock("Z00",.T.)
   Z00->Z00_ALIAS := cTIPO
   Z00->Z00_COD   := "000000"
   MsUnlock("Z00")
Endif   

RecLock("Z00",.F.)
cRET         := SOMA1(Z00->Z00_COD)
Z00->Z00_COD := cRET
MsUnlock("Z00")


Return cRET
