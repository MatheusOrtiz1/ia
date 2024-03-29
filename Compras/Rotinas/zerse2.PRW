
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
User Function zerse2()

Local lRet 		:= .T.
Local nTamCampo := 0      
Local ce2_num	:= Alltrim(M->E2_NUM)

For nTamCampo := 1 to Len(ce2_num)
    If !isdigit(Substr(ce2_num,nTamCampo,nTamCampo))
		Alert("Este campo n�o aceita letras, apenas n�meros, por favor digite novamente.")            
		lRet := .F.
		Return lRet    
    EndIf    
Next

M->E2_NUM  :=Strzero(VAL(M->E2_NUM),9)

Return lRet