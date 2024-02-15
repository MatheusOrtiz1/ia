
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � AGU030	� Autor � Clarice S. Bays       � Data � 15.02.09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao para incluir zeros a esquerda no numero da nota  ���
���          � fiscal de entrada.    									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 									   			  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
User Function zersf1()

Local lRet 		:= .T.
Local nTamCampo := 0      
Local cF1_DOC	:= Alltrim(CNFISCAL)

For nTamCampo := 1 to Len(cF1_DOC)
    If !isdigit(Substr(cF1_DOC,nTamCampo,nTamCampo))
		Alert("Este campo n�o aceita letras, apenas n�meros, por favor digite novamente.")            
		lRet := .F.
		Return lRet    
    EndIf    
Next

CNFISCAL  :=Strzero(VAL(CNFISCAL),9)

Return lRet
