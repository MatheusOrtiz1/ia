
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
User Function zerse1()

Local lRet 		:= .T.
Local nTamCampo := 0      
Local ce1_num	:= Alltrim(M->E1_NUM)

For nTamCampo := 1 to Len(ce1_num)
    If !isdigit(Substr(ce1_num,nTamCampo,nTamCampo))
		Alert("Este campo n�o aceita letras, apenas n�meros, por favor digite novamente.")            
		lRet := .F.
		Return lRet    
    EndIf    
Next

M->E1_NUM  :=Strzero(VAL(M->E1_NUM),9)

Return lRet
