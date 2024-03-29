/*�����������������������������������������������������������������������Ŀ��
���Funcao    �MT110LOK   � Aut.  �Everton Forti         � Data �22.10.2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao Conta Or�amentaria + Centro de Custo Tabela Z01   ���
�������������������������������������������������������������������������Ĵ��
���M�dulo: Compras   			Rotina:Solicita��o de Compraas            ���
�������������������������������������������������������������������������Ĵ*/

User Function MT110LOK()

Local nPosCcus    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
Local nPosClvl   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CLVL'})
Local nPosCo	  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CO'})
Local lValido 	  := .F.
Local MVPCOSDCT	  := SUPERGETMV("MV_UCOXCC",.F.,.F.)//Ativa valida��o tabela Z01 CO X CC
Local MVUCTTCTH	  := SUPERGETMV("MV_UCTTCTH",.F.,.F.)//Ativa valida��o tabela Z32 CLVL X CC  Adicionado 15/12/2022

IF MVPCOSDCT == .F.
	lValido	:= .T.
ELSE
	
	dbSelectArea('Z01')
	dbSetOrder(1)
	If dbseek(xFilial('Z01')+aCols[n][nPosCo]+aCols[n][nPosCcus])
		lValido := .T.
	Else
		msgAlert("Esta Conta Or�ament�ria n�o pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento or�ament�rio!","MT110LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

IF MVUCTTCTH == .F. //Adicionado 15/12/2022
	//lValido	:= .T.
ELSEif lValido
	
	dbSelectArea('Z32')
	dbSetOrder(1)
	If dbseek(xFilial('Z32')+aCols[n][nPosCcus]+aCols[n][nPosClvl])
		lValido := .T.
	Else
		msgAlert("Esta Classe de Valor n�o pode ser utilizada para este Centro de Custo, verifique relacionamento no acompanhamento or�ament�rio!","MT110LOK")
		lValido := .F.
		Return(lValido)
	EndIf
ENDIF

Return(lValido) 
